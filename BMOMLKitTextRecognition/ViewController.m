//
//  ViewController.m
//  BMOMLKitTextRecognition
//
//  Created by Breno Medeiros on 05/01/21.
//

#import "ViewController.h"

#import "UIUtilities.h"



static NSString *const detectionNoResultsMessage = @"No results returned.";



@interface ViewController ()

/** A string holding current results from detection. */
@property(nonatomic) NSMutableString *resultsText;
/** An overlay view that displays detection annotations. */
@property(nonatomic) UIView *annotationOverlayView;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *detectButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Prevent keyboard from showing up when editing read-only text field
    _textView.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Parar e esconder o Indicador de atividade do OCR
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



- (IBAction)scanReceipts:(id)sender {
    
    // Exibir e executar o Indicador de atividade do OCR
    [_activityIndicator startAnimating];
    _activityIndicator.hidden = NO;
    
    
    [self clearResults];
    [self detectTextOnDeviceInImage:_imageView.image];
}



/** Clears the results text view and removes any frames that are visible. */
- (void)clearResults {
    /** Removes the detection annotations from the annotation overlay view. */
    for (UIView *annotationView in _annotationOverlayView.subviews) {
        [annotationView removeFromSuperview];
    }
    
    self.resultsText = [NSMutableString new];
    
    // Clean the text to the textField
    self->_textView.text = @"";
}



/**
 * Detects text on the specified image and draws a frame around the recognized text using the
 * On-Device text recognizer.
 *
 * @param image The image.
 */
- (void)detectTextOnDeviceInImage:(UIImage *)image {
    if (!image) {
        return;
    }

    
    // [START init_text]
    MLKTextRecognizer *onDeviceTextRecognizer = [MLKTextRecognizer textRecognizer];
    // [END init_text]

    // Initialize a VisionImage object with the given UIImage.
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;

    [self.resultsText appendString:@"Running On-Device Text Recognition...\n"];
    [self process:visionImage withTextRecognizer:onDeviceTextRecognizer];
    //printf("%s", self.resultsText);
}



- (void)process:(MLKVisionImage *)visionImage
    withTextRecognizer:(MLKTextRecognizer *)textRecognizer {
  __weak typeof(self) weakSelf = self;
  // [START recognize_text]
  [textRecognizer
      processImage:visionImage
        completion:^(MLKText *_Nullable text, NSError *_Nullable error) {
      
      // Parar e esconder o Indicador de atividade do OCR
      [self->_activityIndicator stopAnimating];
      self->_activityIndicator.hidden = YES;
      
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (text == nil) {
        // [START_EXCLUDE]
        strongSelf.resultsText = [NSMutableString
            stringWithFormat:@"Text recognizer failed with error: %@",
                             error ? error.localizedDescription : detectionNoResultsMessage];
        [strongSelf showResults];
        // [END_EXCLUDE]
        return;
      }
      
      // Add the text to the textField so user can see and copy the result
      self->_textView.text = text.text;

      // [START_EXCLUDE]
      // Blocks.
      for (MLKTextBlock *block in text.blocks) {
        CGRect transformedRect =
            CGRectApplyAffineTransform(block.frame, [strongSelf transformMatrix]);
        [UIUtilities addRectangle:transformedRect
                           toView:self.annotationOverlayView
                            color:UIColor.purpleColor];

        // Lines.
        for (MLKTextLine *line in block.lines) {
          CGRect transformedRect =
              CGRectApplyAffineTransform(line.frame, [strongSelf transformMatrix]);
          [UIUtilities addRectangle:transformedRect
                             toView:strongSelf.annotationOverlayView
                              color:UIColor.orangeColor];

          // Elements.
          for (MLKTextElement *element in line.elements) {
            CGRect transformedRect =
                CGRectApplyAffineTransform(element.frame, [strongSelf transformMatrix]);
            [UIUtilities addRectangle:transformedRect
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
      // [END_EXCLUDE]
    }];
    // [END recognize_text]
}



- (void)showResults {
  UIAlertController *resultsAlertController =
      [UIAlertController alertControllerWithTitle:@"Detection Results"
                                          message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
  [resultsAlertController
      addAction:[UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *_Nonnull action) {
                                         [resultsAlertController dismissViewControllerAnimated:YES
                                                                                    completion:nil];
                                       }]];
  resultsAlertController.message = _resultsText;
  resultsAlertController.popoverPresentationController.barButtonItem = _detectButton;
  resultsAlertController.popoverPresentationController.sourceView = self.view;
  [self presentViewController:resultsAlertController animated:YES completion:nil];
  NSLog(@"%@", _resultsText);
}



- (CGAffineTransform)transformMatrix {
    UIImage *image = _imageView.image;
  if (!image) {
    return CGAffineTransformMake(0, 0, 0, 0, 0, 0);
  }
    CGFloat imageViewWidth = _imageView.frame.size.width;
    CGFloat imageViewHeight = _imageView.frame.size.height;
  CGFloat imageWidth = image.size.width;
  CGFloat imageHeight = image.size.height;

  CGFloat imageViewAspectRatio = imageViewWidth / imageViewHeight;
  CGFloat imageAspectRatio = imageWidth / imageHeight;
  CGFloat scale = (imageViewAspectRatio > imageAspectRatio) ? imageViewHeight / imageHeight
                                                            : imageViewWidth / imageWidth;

  // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
  // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
  CGFloat scaledImageWidth = imageWidth * scale;
  CGFloat scaledImageHeight = imageHeight * scale;
  CGFloat xValue = (imageViewWidth - scaledImageWidth) / 2.0;
  CGFloat yValue = (imageViewHeight - scaledImageHeight) / 2.0;

  CGAffineTransform transform =
      CGAffineTransformTranslate(CGAffineTransformIdentity, xValue, yValue);
  return CGAffineTransformScale(transform, scale, scale);
}


@end
