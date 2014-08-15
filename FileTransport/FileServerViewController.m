#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>
#include <net/ethernet.h>

//#include "GetAddresses.h"

#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))

#define BUFFERSIZE  4000

//int MAXADDRS = 32;
#define MAXADDRS 32

char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];
unsigned long ip_addrs[MAXADDRS];

static int   nextAddr = 0;

void InitAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        ip_addrs[i] = 0;
    }
}

void FreeAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if (if_names[i] != 0) free(if_names[i]);
        if (ip_names[i] != 0) free(ip_names[i]);
        if (hw_addrs[i] != 0) free(hw_addrs[i]);
        ip_addrs[i] = 0;
    }
    InitAddresses();
}

void GetIPAddresses()
{
    int                 i, len, flags;
    char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf       ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in  *sin;
    
    char temp[80];
    
    int sockfd;
    
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = NULL;
        ip_addrs[i] = 0;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        perror("ioctl error");
        return;
    }
    
    lastname[0] = 0;
    
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len;  // for next one in buffer
        
        if (ifr->ifr_addr.sa_family != AF_INET)
        {
            continue;   // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
        {
            *cptr = 0;      // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
        {
            continue;   /* already processed this interface */
        }
        
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0)
        {
            continue;   // ignore if interface not up
        }
        
        if_names[nextAddr] = (char *)malloc(strlen(ifr->ifr_name)+1);
        if (if_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(if_names[nextAddr], ifr->ifr_name);
        
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        
        ip_names[nextAddr] = (char *)malloc(strlen(temp)+1);
        if (ip_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(ip_names[nextAddr], temp);
        
        ip_addrs[nextAddr] = sin->sin_addr.s_addr;
        
        ++nextAddr;
    }
    
    close(sockfd);
}

void GetHWAddresses()
{
    struct ifconf ifc;
    struct ifreq *ifr;
    int i, sockfd;
    char buffer[BUFFERSIZE], *cp, *cplim;
    char temp[80];
    
    for (i=0; i<MAXADDRS; ++i)
    {
        hw_addrs[i] = NULL;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0)
    {
        perror("ioctl error");
        close(sockfd);
        return;
    }
    
    ifr = ifc.ifc_req;
    
    cplim = buffer + ifc.ifc_len;
    
    for (cp=buffer; cp < cplim; )
    {
        ifr = (struct ifreq *)cp;
        if (ifr->ifr_addr.sa_family == AF_LINK)
        {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            int a,b,c,d,e,f;
            int i;
            
            strcpy(temp, (char *)ether_ntoa((const struct ether_addr *)LLADDR(sdl)));
            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
            
            for (i=0; i<MAXADDRS; ++i)
            {
                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0))
                {
                    if (hw_addrs[i] == NULL)
                    {
                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);
                        strcpy(hw_addrs[i], temp);
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    
    close(sockfd);
}



#import "FileServerViewController.h"
#import "ContentsViewController.h"

@interface FileServerViewController ()

@end

@implementation FileServerViewController
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
    
    self.lab_state.text = @"未监听";
    
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    self.lab_IP.text = [NSString stringWithFormat:@"%s",ip_names[1]];
    NSLog(@"%s",ip_names[1]);
    
    self.textField_Port.text = @"1234";
    
    self.fileData = [[NSMutableData alloc]init];
    
    fileManager = [[NSFileManager alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(UIButton *)sender {
    if (!socket) {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    NSString *ip = self.lab_IP.text;
    if (!ip) {
        NSLog(@"无网络连接！");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无网络连接！" delegate:Nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString *port = self.textField_Port.text;
    if (!port) {
        NSLog(@"端口号为空！");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"端口号为空！" delegate:Nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSError *error = nil;
    [socket acceptOnPort:[port integerValue] error:&error];
    self.lab_state.text = @"监听中";
}

- (IBAction)openFolder:(UIButton *)sender {
    NSError *error = nil;
    NSArray *list = [fileManager contentsOfDirectoryAtPath:[self documentPath] error:&error];
    if (!list) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"目录为空，没有文件！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        ContentsViewController *contentsVC = [[ContentsViewController alloc]init];
        [self.navigationController pushViewController:contentsVC animated:YES];
        contentsVC.serverOrClient = NO;
    }
}
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{   
    s = newSocket;
    s.delegate = self;
    [s readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [s writeData:data withTimeout:-1 tag:0];
//    NSLog(@"收到数据：%lu 字节！",(unsigned long)[data length]);
    [s readDataWithTimeout:-1 tag:0];
    
    [self.fileData appendData:data];
    
    
    NSRange range1 = NSMakeRange(0, 16);
    NSData *dataLength1 = [self.fileData subdataWithRange:range1];
    NSString *length1 = [[NSString alloc]initWithData:dataLength1 encoding:NSUTF8StringEncoding];
    unsigned long l1 = [length1 intValue];
    
    NSRange range2 = NSMakeRange(16, 16);
    NSData *dataLength2 = [self.fileData subdataWithRange:range2];
    NSString *length2 = [[NSString alloc]initWithData:dataLength2 encoding:NSUTF8StringEncoding];
    unsigned long l2 = [length2 intValue];
    
    NSRange range3 = NSMakeRange(32, l2);
    NSData *dataLength3 = [self.fileData subdataWithRange:range3];
    NSString *length3 = [[NSString alloc]initWithData:dataLength3 encoding:NSUTF8StringEncoding];
    
    
    
    unsigned long lD = [self.fileData length];
    
    if (l1 == (lD -16-16-l2)) {
        
        if ([fileManager fileExistsAtPath:[self documentPath]]) {
            NSString *path = [NSString stringWithFormat:@"%@/%@",[self documentPath],length3];
            NSRange range4 = NSMakeRange(l2+32, l1);
            NSData *dataLength4 = [self.fileData subdataWithRange:range4];
            [dataLength4 writeToFile:path atomically:YES];
            
            [self.fileData setLength:0];
        }
    }
    
}


-(NSString *)documentPath{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentPath = [paths objectAtIndex:0];
    return documentPath;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
