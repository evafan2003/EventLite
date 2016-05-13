//
//  WSNumberKeyBoard.h
//  menswear
//
//  Created by wuzhensong on 14/12/11.
//  Copyright (c) 2014年 menswear. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnBlock) (UITextField *);

@interface WSNumberKeyBoard : UIView

- (id)initWithControlTextField:(UITextField *)textField
              ReturnButtonName:(NSString *)returnName
                 andClickBlock:(ReturnBlock)block;
@end

