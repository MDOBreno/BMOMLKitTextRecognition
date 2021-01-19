//
//  UIUtillities.m
//  BMOMLKitRecognition
//
//  Created by Breno Medeiros on 18/01/21.
//

#import "UIUtillities.h"

static CGFloat const rectangleViewAlpha = 0.3;
static CGFloat const rectangleViewCornerRadius = 10.0;

NS_ASSUME_NONNULL_BEGIN

@implementation UIUtillities

+ (void) addRectangle:(CGRect)rectangle toView:(UIView *)view color:(UIColor *)color {
    UIView *rectangleView = [[UIView alloc] initWithFrame:rectangle];
    rectangleView.layer.cornerRadius = rectangleViewCornerRadius;
    rectangleView.alpha = rectangleViewAlpha;
    rectangleView.backgroundColor = color;
    [view addSubview:rectangleView];
}

@end

NS_ASSUME_NONNULL_END
