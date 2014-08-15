//
//  FileClientViewController.h
//  FileTransport
//
//  Created by SKYA03  on 14-3-12.
//  Copyright (c) 2014年 SKYA03 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"


@interface FileClientViewController : UIViewController<GCDAsyncSocketDelegate,UITextFieldDelegate>
{
    GCDAsyncSocket *socket;
}
@property (weak, nonatomic) IBOutlet UITextField *textField_IP;
@property (weak, nonatomic) IBOutlet UITextField *textField_Port;
@property (weak, nonatomic) IBOutlet UILabel *lab_state;
- (IBAction)start:(UIButton *)sender;
- (IBAction)chooeseFile:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
- (IBAction)connect:(UIButton *)sender;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (strong,nonatomic) NSString *fileNameStr;
@end
