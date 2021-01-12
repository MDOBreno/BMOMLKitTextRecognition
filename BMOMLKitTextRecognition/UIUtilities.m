//
//  UIUtilities.m
//  BMOMLKitTextRecognition
//
//  Created by Breno Medeiros on 10/01/21.
//

#import "UIUtilities.h"

static CGFloat const circleViewAlpha = 0.7;
static CGFloat const rectangleViewAlpha = 0.3;
static CGFloat const shapeViewAlpha = 0.3;
static CGFloat const rectangleViewCornerRadius = 10.0;

NS_ASSUME_NONNULL_BEGIN

@implementation UIUtilities

+ (void)addCircleAtPoint:(CGPoint)point
                  toView:(UIView *)view
                   color:(UIColor *)color
                  radius:(CGFloat)radius {
  CGFloat divisor = 2.0;
  CGFloat xCoord = point.x - radius / divisor;
  CGFloat yCoord = point.y - radius / divisor;
  CGRect circleRect = CGRectMake(xCoord, yCoord, radius, radius);
  UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
  circleView.layer.cornerRadius = radius / divisor;
  circleView.alpha = circleViewAlpha;
  circleView.backgroundColor = color;
  [view addSubview:circleView];
}

+ (void)addLineSegmentFromPoint:(CGPoint)fromPoint
                        toPoint:(CGPoint)toPoint
                         inView:(UIView *)view
                          color:(UIColor *)color
                          width:(CGFloat)width {
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:fromPoint];
  [path addLineToPoint:toPoint];
  CAShapeLayer *lineLayer = [CAShapeLayer layer];
  lineLayer.path = path.CGPath;
  lineLayer.strokeColor = color.CGColor;
  lineLayer.fillColor = nil;
  lineLayer.opacity = 1.0f;
  lineLayer.lineWidth = width;
  UIView *lineView = [[UIView alloc] initWithFrame:view.bounds];
  [lineView.layer addSublayer:lineLayer];
  [view addSubview:lineView];
}

+ (void)addRectangle:(CGRect)rectangle toView:(UIView *)view color:(UIColor *)color {
  UIView *rectangleView = [[UIView alloc] initWithFrame:rectangle];
  rectangleView.layer.cornerRadius = rectangleViewCornerRadius;
  rectangleView.alpha = rectangleViewAlpha;
  rectangleView.backgroundColor = color;
  [view addSubview:rectangleView];
}

+ (void)addShapeWithPoints:(NSArray<NSValue *> *)points
                    toView:(UIView *)view
                     color:(UIColor *)color {
  UIBezierPath *path = [UIBezierPath new];
  for (int i = 0; i < [points count]; i++) {
    CGPoint point = points[i].CGPointValue;
    if (i == 0) {
      [path moveToPoint:point];
    } else {
      [path addLineToPoint:point];
    }
    if (i == points.count - 1) {
      [path closePath];
    }
  }
  CAShapeLayer *shapeLayer = [CAShapeLayer new];
  shapeLayer.path = path.CGPath;
  shapeLayer.fillColor = color.CGColor;
  CGRect rect = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
  UIView *shapeView = [[UIView alloc] initWithFrame:rect];
  shapeView.alpha = shapeViewAlpha;
  [shapeView.layer addSublayer:shapeLayer];
  [view addSubview:shapeView];
}

+ (UIImageOrientation)imageOrientation {
  return [self imageOrientationFromDevicePosition:AVCaptureDevicePositionBack];
}

+ (UIImageOrientation)imageOrientationFromDevicePosition:(AVCaptureDevicePosition)devicePosition {
  UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
  if (deviceOrientation == UIDeviceOrientationFaceDown ||
      deviceOrientation == UIDeviceOrientationFaceUp ||
      deviceOrientation == UIDeviceOrientationUnknown) {
    deviceOrientation = [self currentUIOrientation];
  }
  switch (deviceOrientation) {
    case UIDeviceOrientationPortrait:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationLeftMirrored
                                                            : UIImageOrientationRight;
    case UIDeviceOrientationLandscapeLeft:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationDownMirrored
                                                            : UIImageOrientationUp;
    case UIDeviceOrientationPortraitUpsideDown:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationRightMirrored
                                                            : UIImageOrientationLeft;
    case UIDeviceOrientationLandscapeRight:
      return devicePosition == AVCaptureDevicePositionFront ? UIImageOrientationUpMirrored
                                                            : UIImageOrientationDown;
    case UIDeviceOrientationFaceDown:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationUnknown:
      return UIImageOrientationUp;
  }
}

+ (UIDeviceOrientation)currentUIOrientation {
  UIDeviceOrientation (^deviceOrientation)(void) = ^UIDeviceOrientation(void) {
    switch (UIApplication.sharedApplication.statusBarOrientation) {
      case UIInterfaceOrientationLandscapeLeft:
        return UIDeviceOrientationLandscapeRight;
      case UIInterfaceOrientationLandscapeRight:
        return UIDeviceOrientationLandscapeLeft;
      case UIInterfaceOrientationPortraitUpsideDown:
        return UIDeviceOrientationPortraitUpsideDown;
      case UIInterfaceOrientationPortrait:
      case UIInterfaceOrientationUnknown:
        return UIDeviceOrientationPortrait;
    }
  };

  if (NSThread.isMainThread) {
    return deviceOrientation();
  } else {
    __block UIDeviceOrientation currentOrientation = UIDeviceOrientationPortrait;
    dispatch_sync(dispatch_get_main_queue(), ^{
      currentOrientation = deviceOrientation();
    });
    return currentOrientation;
  }
}

@end

NS_ASSUME_NONNULL_END