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

+ (void)addCircleAtPoint:(CGPoint)point
                  toView:(UIView *)view
                   color:(UIColor *)color
                  radius:(CGFloat)radius;

+ (void)addLineSegmentFromPoint:(CGPoint)fromPoint
                        toPoint:(CGPoint)toPoint
                         inView:(UIView *)view
                          color:(UIColor *)color
                          width:(CGFloat)width;

+ (void)addRectangle:(CGRect)rectangle toView:(UIView *)view color:(UIColor *)color;
+ (void)addShapeWithPoints:(NSArray<NSValue *> *)points
                    toView:(UIView *)view
                     color:(UIColor *)color;
+ (UIImageOrientation)imageOrientation;
+ (UIImageOrientation)imageOrientationFromDevicePosition:(AVCaptureDevicePosition)devicePosition;
+ (UIDeviceOrientation)currentUIOrientation;

@end

NS_ASSUME_NONNULL_END
