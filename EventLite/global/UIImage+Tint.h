//
//  UIImage+Tint.h
//  EventLite
//
//  Created by wsjtwzs on 15/2/10.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

/**
 *  改变图片的颜色
 *  相关文档：http://www.onevcat.com/2013/04/using-blending-in-ios/
 */

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
/**
 *  保留渐变（灰度）
 *
 *  @param tintColor
 *
 *  @return
 */
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

- (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

@end
