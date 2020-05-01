//
//  SGFileUploadViewController.m
//  codeSprite
//
//  Created by 11 on 12/20/15.
//  Copyright © 2015 soulghost. All rights reserved.
//

#import "SGFileUploadViewController.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "HYBIPHelper.h"
#import "SGIndexManager.h"
#import "SGFileUploadView.h"

@interface SGFileUploadViewController ()

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, assign, getter=isFileUploading) BOOL fileUploading;
@property (nonatomic, weak) SGFileUploadView *uploadView;
@property (nonatomic, weak) MBProgressHUD *hud;

@end

@implementation SGFileUploadViewController

- (void)loadView {
    SGFileUploadView *uploadView = [SGFileUploadView new];
    self.uploadView = uploadView;
    self.view = uploadView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(itemClick:)];
    self.navigationItem.rightBarButtonItem = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadStart:) name:SGFileUploadDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinish:) name:SGFileUploadDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadProgress:) name:SGFileUploadProgressNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    HTTPServer *httpServer = [[HTTPServer alloc] init];
    httpServer.port = 52013;
    self.httpServer = httpServer;
    [httpServer setType:@"_http._tcp."];
    NSString *webPath = [[NSBundle mainBundle] resourcePath];
    [httpServer setDocumentRoot:webPath];
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    NSError *err;
    if ([httpServer start:&err]) {
        if ([HYBIPHelper deviceIPAdress] == nil) {
            [self.uploadView setAddress:@"Error, your iPhone is not connected to WiFi"];
            return; 
        }
        NSString *ip_port = [NSString stringWithFormat:@"http://%@:%hu",[HYBIPHelper deviceIPAdress],[httpServer listeningPort]];
        [self.uploadView setAddress:ip_port];
    }else{
        [self.uploadView setAddress:@"HttpServer cannot start"];
    }
}

#pragma mark Notification Callback
- (void)fileUploadStart:(NSNotification *)nof {
    NSString *fileName = nof.object[@"fileName"];
    UIView *topView = [[UIApplication sharedApplication].windows lastObject].rootViewController.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:topView animated:YES];
    hud.label.text = [NSString stringWithFormat:@"Uploading %@",fileName];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.removeFromSuperViewOnHide = YES;
    self.hud = hud;
    self.fileUploading = YES;
}

- (void)fileUploadFinish:(NSNotification *)nof {
    [MBProgressHUD hideHUD];
    if (self.fileUploading) {
        self.fileUploading = NO;
        [MBProgressHUD showSuccess:@"Upload Succeeded"];
    }
}

- (void)fileUploadProgress:(NSNotification *)nof {
    CGFloat progress = [nof.object[@"progress"] doubleValue];
    self.hud.progress = progress;
}

- (void)itemClick:(UIBarButtonItem *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.httpServer stop];
    self.httpServer = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
