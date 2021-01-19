//
//  ViewController.m
//  BMOMLKitRecognition
//
//  Created by Breno Medeiros on 18/01/21.
//

#import "ViewController.h"

#import "UIUtillities.h"


static NSString *const detectionNoResultsMessage = @"No results returned.";



@interface ViewController ()

// Increasing String to recognized words
@property(nonatomic) NSMutableString *resultsText;

// Our view to draw the recognized texts
@property(nonatomic) UIView *annotationOverlayView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Dont open keyboard when hit TextField
    _textView.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Stop Animation
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    
    _imageView.image = [UIImage imageNamed:@"image_has_text"];
    _annotationOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    _annotationOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
    _annotationOverlayView.clipsToBounds = YES;
    [_imageView addSubview:_annotationOverlayView];
    [NSLayoutConstraint activateConstraints:@[
        [_annotationOverlayView.topAnchor constraintEqualToAnchor:_imageView.topAnchor],
        [_annotationOverlayView.leadingAnchor constraintEqualToAnchor:_imageView.leadingAnchor],
        [_annotationOverlayView.trailingAnchor constraintEqualToAnchor:_imageView.trailingAnchor],
        [_annotationOverlayView.bottomAnchor constraintEqualToAnchor:_imageView.bottomAnchor]
    ]];
}

- (IBAction)scanDocument:(id)sender {
    [_activityIndicator startAnimating];
    _activityIndicator.hidden = NO;
    
    [self clearResults];
    [self detectTextOnDeviceInImage:_imageView.image];
}

- (void) clearResults {
    
    for (UIView *annotationView in _annotationOverlayView.subviews) {
        [annotationView removeFromSuperview];
    }
    
    self.resultsText = [NSMutableString new];
    
    self->_textView.text = @"";
}

- (void) detectTextOnDeviceInImage:(UIImage *)image {
    if (!image) {
        return;
    }
    
    MLKTextRecognizer *onDeviceTextRecognizer = [MLKTextRecognizer textRecognizer];
    
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    
    [self.resultsText appendString:@"Running On-Device Text Recognition...\n"];
    [self process:visionImage withTextRecognizer:onDeviceTextRecognizer];
}

-(void) process:(MLKVisionImage *)visionImage withTextRecognizer:(MLKTextRecognizer *)textRecognizer {
    __weak typeof(self) weakSelf = self;
    //[START recognize_text];
    [textRecognizer processImage:visionImage completion:^(MLKText * _Nullable text, NSError * _Nullable error) {
        [self->_activityIndicator stopAnimating];
        self->_activityIndicator.hidden = YES;
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (text == nil) {
            //STARK EXCLUDE
            strongSelf.resultsText = [NSMutableString
                stringWithFormat:@"Text recognizer failed with error: %@",
                                 error ? error.localizedDescription : detectionNoResultsMessage];
            [strongSelf showResults];
            //END EXCLUDE
            return;
        }
        
        self->_textView.text = text.text;
        
        //Showing over Image the text recognized by Drawing
        
        //BLOCKS
        for (MLKTextBlock *block in text.blocks) {
            CGRect transformatedRect = CGRectApplyAffineTransform(block.frame, [strongSelf transformMatrix]);
            [UIUtillities addRectangle:transformatedRect
                                toView:self.annotationOverlayView
                                 color:UIColor.purpleColor];
            
            //LINES
            for (MLKTextLine *line in block.lines) {
                CGRect transformedRect = CGRectApplyAffineTransform(line.frame,[strongSelf transformMatrix]);
                [UIUtillities addRectangle:transformedRect
                                    toView:strongSelf.annotationOverlayView
                                     color:UIColor.orangeColor];
                
                //ELEMENTS(Words)
                //LINES
                for (MLKTextElement *element in line.elements) {
                    CGRect transformedRect = CGRectApplyAffineTransform(element.frame, [strongSelf transformMatrix]);
                    [UIUtillities addRectangle:transformedRect
                                        toView:strongSelf.annotationOverlayView
                                         color:UIColor.greenColor];
                    UILabel *label = [[UILabel alloc] initWithFrame:transformedRect];
                    label.text = element.text;
                    label.adjustsFontSizeToFitWidth = YES;
                    [strongSelf.annotationOverlayView addSubview:label];
                }
            }
        }
        [strongSelf.resultsText appendFormat:@"%@\n", text.text];
        [strongSelf showResults];
        //END of recognition
    }];
    //[END recognize_text];
}

-(void) showResults {
    UIAlertController *resultsAlertController = [UIAlertController alertControllerWithTitle:@"Detection Results"
                                                                                    message:nil
                                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    [resultsAlertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
        [resultsAlertController dismissViewControllerAnimated:YES
                                                   completion:nil];
    }]];
    resultsAlertController.message = _resultsText;
    
    resultsAlertController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:resultsAlertController animated:YES completion:nil];
    NSLog(@"%@", _resultsText);
}

-(CGAffineTransform)transformMatrix {
    UIImage *image = _imageView.image;
    if (!image) {
        return CGAffineTransformMake(0, 0, 0, 0, 0, 0);
    }
    
    CGFloat imageViewWidth = _imageView.frame.size.width;
    CGFloat imageViewHeight = _imageView.frame.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGFloat imageViewAspectRatio = imageViewWidth / imageViewHeight;
    CGFloat scale = (imageViewAspectRatio > imageViewAspectRatio) ? imageViewHeight / imageHeight
                                                                  : imageViewWidth / imageWidth;
    
    CGFloat ScaledImageWidth = imageWidth * scale;
    CGFloat ScaledImageHeight = imageHeight * scale;
    CGFloat xValue = (imageViewWidth - ScaledImageWidth) / 2.0;
    CGFloat yValue = (imageViewHeight - ScaledImageHeight) / 2.0;
    
    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, xValue, yValue);
    return CGAffineTransformScale(transform, scale, scale);
}

@end
