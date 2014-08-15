//
//  FileServerViewController.h
//  FileTransport
//
//  Created by SKYA03  on 14-3-12.
//  Copyright (c) 2014年 SKYA03 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface FileServerViewController : UIViewController<GCDAsyncSocketDelegate,UITextFieldDelegate>
{
    GCDAsyncSocket *socket;
    GCDAsyncSocket *s;
}
@property (weak, nonatomic) IBOutlet UILabel *lab_IP;
@property (weak, nonatomic) IBOutlet UITextField *textField_Port;
@property (weak, nonatomic) IBOutlet UILabel *lab_state;
- (IBAction)start:(UIButton *)sender;
- (IBAction)openFolder:(UIButton *)sender;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableData *fileData;

@end
