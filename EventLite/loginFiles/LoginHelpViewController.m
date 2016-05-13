//
//  LoginHelpViewController.m
//  EventLite
//
//  Created by 魔时网 on 14-3-31.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "LoginHelpViewController.h"

static CGFloat scrollHeight = 1170.0f;

@interface LoginHelpViewController ()

@end

@implementation LoginHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.baseScrollView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    self.baseScrollView.contentSize = CGSizeMake(SCREENWIDTH, scrollHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
