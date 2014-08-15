//
//  AppDelegate.h
//  FileTransport
//
//  Created by SKYA03  on 14-3-12.
//  Copyright (c) 2014年 SKYA03 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) UINavigationController *navCon;

@end
