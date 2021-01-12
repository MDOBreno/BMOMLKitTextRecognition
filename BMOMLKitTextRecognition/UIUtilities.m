//
//  UIUtilities.m
//  BMOMLKitTextRecognition
//
//  Created by Breno Medeiros on 10/01/21.
//

#import "UIUtilities.h"

static CGFloat const rectangleViewAlpha = 0.3;
static CGFloat const rectangleViewCornerRadius = 10.0;

NS_ASSUME_NONNULL_BEGIN

@implementation UIUtilities


+ (void)addRectangle:(CGRect)rectangle toView:(UIView *)view color:(UIColor *)color {
    UIView *rectangleView = [[UIView alloc] initWithFrame:rectangle];
    rectangleView.layer.cornerRadius = rectangleViewCornerRadius;
    rectangleView.alpha = rectangleViewAlpha;
    rectangleView.backgroundColor = color;
    [view addSubview:rectangleView];
}

@end

NS_ASSUME_NONNULL_END
