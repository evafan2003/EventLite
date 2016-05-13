//
//  WSNumberKeyBoard.m
//  menswear
//
//  Created by wuzhensong on 14/12/11.
//  Copyright (c) 2014年 menswear. All rights reserved.
//

#import "WSNumberKeyBoard.h"

#define kLineWidth 1
#define kNumFont [UIFont systemFontOfSize:27]

#define LETTERARRAY [NSArray arrayWithObjects:@"ABC",@"DEF",@"GHI",@"JKL",@"MNO",@"PQRS",@"TUV",@"WXYZ", nil]

static CGFloat keyboard_height = 216.0f;

@interface WSNumberKeyBoard()
{
    NSString *_returnName;
}

@property (nonatomic, copy) ReturnBlock returnBlock;
@property (nonatomic, weak) UITextField *controlTextField;
@end

@implementation WSNumberKeyBoard

- (id)initWithControlTextField:(UITextField *)textField
              ReturnButtonName:(NSString *)returnName
                 andClickBlock:(ReturnBlock)block
{
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), keyboard_height);
        self.returnBlock = block;
        self.controlTextField  =textField;
        _returnName = returnName;
        
        //createButton
        for (int i=0; i<4; i++)
        {
            for (int j=0; j<3; j++)
            {
                UIButton *button = [self creatButtonWithX:i Y:j];
                [self addSubview:button];
            }
        }
        
        //createLine
        UIColor *color = [UIColor colorWithRed:188/255.0 green:192/255.0 blue:199/255.0 alpha:1];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/3, 0, kLineWidth, 216)];
        line1.backgroundColor = color;
        [self addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/3*2, 0, kLineWidth, 216)];
        line2.backgroundColor = color;
        [self addSubview:line2];
        
        for (int i=0; i<3; i++)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, keyboard_height/4*(i+1), CGRectGetWidth(self.bounds), kLineWidth)];
            line.backgroundColor = color;
            [self addSubview:line];
        }
        
    }
    return self;
}

-(UIButton *)creatButtonWithX:(NSInteger) x Y:(NSInteger) y
{
    UIButton *button;
    //
    CGFloat frameX;
    CGFloat frameW;
    switch (y)
    {
        case 0:
            frameX = 0.0;
            frameW = CGRectGetWidth(self.bounds)/3;
            break;
        case 1:
            frameX = CGRectGetWidth(self.bounds)/3;
            frameW = CGRectGetWidth(self.bounds)/3;
            break;
        case 2:
            frameX = CGRectGetWidth(self.bounds)/3*2;
            frameW = CGRectGetWidth(self.bounds)/3;
            break;
            
        default:
            break;
    }
    CGFloat frameY = keyboard_height/4*x;
    
    //
    button = [[UIButton alloc] initWithFrame:CGRectMake(frameX, frameY, frameW, keyboard_height/4)];
    
    //
    NSInteger num = y+3*x+1;
    button.tag = num;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *colorNormal = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
    UIColor *colorHightlighted = [UIColor colorWithRed:186.0/255 green:189.0/255 blue:194.0/255 alpha:1.0];
    
    if (num == 10 || num == 12)
    {
        UIColor *colorTemp = colorNormal;
        colorNormal = colorHightlighted;
        colorHightlighted = colorTemp;
    }
    button.backgroundColor = colorNormal;
    CGSize imageSize = CGSizeMake(frameW, keyboard_height/4);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [colorHightlighted set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [button setImage:pressedColorImg forState:UIControlStateHighlighted];
    
    
    
    if (num<10)
    {
        UILabel *labelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frameW, 28)];
        labelNum.text = [NSString stringWithFormat:@"%ld",(long)num];
        labelNum.textColor = [UIColor blackColor];
        labelNum.textAlignment = NSTextAlignmentCenter;
        labelNum.font = kNumFont;
        [button addSubview:labelNum];
        
        if (num != 1)
        {
            UILabel *labelLetter = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, frameW, 16)];
            labelLetter.text = [LETTERARRAY objectAtIndex:num-2];
            labelLetter.textColor = [UIColor blackColor];
            labelLetter.textAlignment = NSTextAlignmentCenter;
            labelLetter.font = [UIFont systemFontOfSize:12];
            [button addSubview:labelLetter];
        }
    }
    else if (num == 11)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frameW, 28)];
        label.text = @"0";
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kNumFont;
        [button addSubview:label];
    }
    else if (num == 10)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frameW, 28)];
        label.text = ((_returnName==nil)?@"完成":_returnName);
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        [button addSubview:label];
    }
    else
    {
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(42, 19, 22, 17)];
        arrow.image = [UIImage imageNamed:@"arrowInKeyboard"];
        [button addSubview:arrow];
        
    }
    
    return button;
}


-(void)clickButton:(UIButton *)sender
{
    if (sender.tag == 10)
    {
        if (self.returnBlock) {
            self.returnBlock(self.controlTextField);
        }
        return;
    }
    else if(sender.tag == 12)
    {
        if ([self.controlTextField respondsToSelector:@selector(setText:)]) {
            
            if (self.controlTextField.text.length != 0)
            {
                [self.controlTextField deleteBackward];
            }
        }
    }
    else
    {
        NSInteger num = sender.tag;
        if (sender.tag == 11)
        {
            num = 0;
        }
        if ([self.controlTextField respondsToSelector:@selector(setText:)]) {
            self.controlTextField.text = [self.controlTextField.text stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)num]];
        }
    }
}


@end

