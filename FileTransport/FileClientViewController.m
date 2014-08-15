//
//  FileClientViewController.m
//  FileTransport
//
//  Created by SKYA03  on 14-3-12.
//  Copyright (c) 2014年 SKYA03 . All rights reserved.
//

#import "FileClientViewController.h"
#import "ContentsViewController.h"


@interface FileClientViewController ()<DidChooesedFile>

@end

@implementation FileClientViewController
@synthesize fileManager;

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
    
    fileManager = [[NSFileManager alloc]init];
    
    self.textField_IP.text = @"10.0.1.82";
    self.textField_Port.text = @"1234";
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(UIButton *)sender {
    if (!_fileNameStr) {
        return;
    }
//    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:FILENAME];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self documentPath],_fileNameStr];
    
    //文件的实际data
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
//    //文件的长度
//    NSString *dataLengthStr = [NSString stringWithFormat:@"%16lu",(unsigned long)[data length]];
//    NSData *dataLength = [dataLengthStr dataUsingEncoding:NSUTF8StringEncoding];
//    
//    //文件名data
//    NSString *fileName = [filePath lastPathComponent];
//    NSData *dataFileName = [fileName dataUsingEncoding:NSUTF8StringEncoding];
//    
//    //文件名长度
//    NSString *dataLengthStr2 = [NSString stringWithFormat:@"%16lu",(unsigned long)[dataFileName length]];
//    NSData *dataLength2 = [dataLengthStr2 dataUsingEncoding:NSUTF8StringEncoding];
//    
//    //发送的数据
//    NSMutableData *dataResult = [[NSMutableData alloc]initWithData:dataLength];
//    [dataResult appendData:dataLength2];
//    [dataResult appendData:dataFileName];
//    [dataResult appendData:data];
    
    
//    [socket writeData:dataResult withTimeout:-1 tag:0];
    [socket writeData:data withTimeout:-1 tag:0];
    [socket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"Data总大小：%lu 字节",(unsigned long)[data length]);                 
    
//    self.lab_state.text = @"已发送";
}

- (IBAction)chooeseFile:(UIButton *)sender {
    NSError *error = nil;
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:[self documentPath] error:&error];
    if (!arr) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"目录为空，没有文件，不能发送！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        ContentsViewController *contentsVC = [[ContentsViewController alloc]init];
        contentsVC.delegate = self;
        [self.navigationController pushViewController:contentsVC animated:YES];
        contentsVC.serverOrClient = YES;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    if (!_fileNameStr) {
        return;
    }
    self.fileName.text = [NSString stringWithFormat:@"~/%@",_fileNameStr];
    self.startBtn.enabled = YES;
}
-(NSString *)documentPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [paths objectAtIndex:0];
    return documentPath;
}
- (IBAction)connect:(UIButton *)sender {
    NSString *ip = self.textField_IP.text;
    NSString *port = self.textField_Port.text;
    if (!ip) {
        NSLog(@"IP地址为空！");
        return;
    }
    if (!port) {
        NSLog(@"端口号为空！");
        return;
    }
    if (!socket) {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    NSError *error = nil;
    [socket connectToHost:ip onPort:[port integerValue] error:&error];
    self.lab_state.text = @"已连接";
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)didChooesedFile:(NSString *)fileName{
    self.fileNameStr = fileName;
}
@end
