//
//  EmptyView.m
//  moshTickets
//
//  Created by 魔时网 on 14-9-15.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "EmptyView.h"
#import "GlobalConfig.h"

static NSString *defaultContent = @"没有内容哦！";
static CGFloat alertLabelMargin_left = 10.0f;
static CGFloat margin_top = 50.0f;
static CGFloat space_labelAndImage = 10.0f;

@implementation EmptyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alertLabel = [GlobalConfig createLabelWithFrame:CGRectZero Text:defaultContent FontSize:14 textColor:[UIColor colorWithRed:134/255.0f green:134/255.0f blue:134/255.0f alpha:1]];
        self.alertLabel.textAlignment = NSTextAlignmentLeft;
        self.alertLabel.numberOfLines = 0;
        [self addSubview:self.alertLabel];
        self.alertView = [GlobalConfig createImageViewWithFrame:CGRectZero ImageName:nil];
        [self addSubview:self.alertView];
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void) setAlertContent:(NSString *)text alertImageName:(NSString *)name
{
    self.alertLabel.text = text;
    self.alertView.image = [GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:name]?[UIImage imageNamed:name]:nil;
    [self setNeedsDisplay];
}


/**
 *  图片和内容设置完成后，重新布局
 */
- (void) setNeedsDisplay
{
    UIImage *image = self.alertView.image;
    if (CGRectEqualToRect(self.alertView.frame, CGRectZero) && image) {
    
        self.alertView.frame = CGRectMake((SCREENWIDTH - image.size.width)/2, margin_top, image.size.width, image.size.height);
    }
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.alertLabel.text]) {
    
        if (CGRectEqualToRect(self.alertLabel.frame, CGRectZero) ) {
            self.alertLabel.frame = CGRectMake(alertLabelMargin_left,margin_top + (image?image.size.height + space_labelAndImage:0), SCREENWIDTH - alertLabelMargin_left*2, 0);
        }
        CGRect rect = self.alertLabel.frame;
        CGSize size = [GlobalConfig getAdjustHeightOfContent:self.alertLabel.text width:CGRectGetWidth(rect) fontSize:self.alertLabel.font.pointSize];
        rect.origin.x = (SCREENWIDTH -  size.width)/2;
        rect.size.width = size.width;
        rect.size.height = size.height;
        self.alertLabel.frame = rect;
    }
}


@end
