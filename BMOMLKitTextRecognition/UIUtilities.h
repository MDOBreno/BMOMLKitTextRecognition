    //
//  UIUtilities.h
//  BMOMLKitTextRecognition
//
//  Created by Breno Medeiros on 10/01/21.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@import MLKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIUtilities : NSObject

+ (void)addRectangle:(CGRect)rectangle toView:(UIView *)view color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
