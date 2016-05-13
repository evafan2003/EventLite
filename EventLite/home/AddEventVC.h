//
//  AddEventVC.h
//  EventLite
//
//  Created by 魔时网 on 15/1/28.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "BaseViewController.h"

@interface AddEventVC : BaseViewController <UITextFieldDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)login:(id)sender;
- (IBAction)urlButtonPress:(id)sender;
- (IBAction)phoneButtonPress:(id)sender;
- (IBAction)getUsernameAndPassword:(id)sender;

@end

