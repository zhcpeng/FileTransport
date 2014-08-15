//
//  MainViewController.m
//  FileTransport
//
//  Created by SKYA03  on 14-3-12.
//  Copyright (c) 2014年 SKYA03 . All rights reserved.
//

#import "MainViewController.h"
#import "FileServerViewController.h"
#import "FileClientViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)send:(UIButton *)sender {
    FileClientViewController *clientVC = [[FileClientViewController alloc]init];
    [self.navigationController pushViewController:clientVC animated:YES];
}

- (IBAction)receive:(UIButton *)sender {
    FileServerViewController *serverVC = [[FileServerViewController alloc]init];
    [self.navigationController pushViewController:serverVC animated:YES];
}
@end
