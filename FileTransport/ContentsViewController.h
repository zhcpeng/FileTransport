//
//  ContentsViewController.h
//  FileTransport
//
//  Created by SKYA03  on 14-3-12.
//  Copyright (c) 2014年 SKYA03 . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DidChooesedFile;

@interface ContentsViewController : UITableViewController

@property (assign, nonatomic) BOOL serverOrClient;  // 0 = server
@property (strong, nonatomic) NSArray *fileList;
@property (strong, nonatomic) NSMutableArray *fileNameList;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (assign, nonatomic) id<DidChooesedFile> delegate;

@end

@protocol DidChooesedFile <NSObject>

-(void)didChooesedFile:(NSString *)fileName;

@end
