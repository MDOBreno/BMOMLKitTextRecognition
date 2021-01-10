//
//  ViewController.h
//  BMOMLKitTextRecognition
//
//  Created by Breno Medeiros on 05/01/21.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    __weak IBOutlet UITextView *textView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIImageView *imageView;
}
    
@property (weak, nonatomic) IBOutlet UIButton *scanReceipts;

@end

