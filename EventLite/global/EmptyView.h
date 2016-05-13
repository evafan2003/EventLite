//
//  EmptyView.h
//  moshTickets
//
//  Created by 魔时网 on 14-9-15.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyView : UIScrollView

@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) UIImageView *alertView;

/**
 *  设置提示文字和图片，设置后自动调整大小
 *
 *  @param text 提示文字
 *  @param name 图片名称
 */
- (void) setAlertContent:(NSString *)text alertImageName:(NSString *)name;


@end
