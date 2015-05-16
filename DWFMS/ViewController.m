//
//  ViewController.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "ViewController.h"
#import "CallServer.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    CallServer *res = [CallServer alloc];
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    [param setValue:@"GCM_ID" forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    
    //deviceId
    
    //R 수신
    
//    NSString* str = [res stringWithUrl:@"getEmcUserInfo.do" VAL:param];

    
    /*
     자동로그인 부분
     */
    
    
    //callUrl=callUrl+"?HP_TEL="+PhoneNumber+"&GCM_ID="+gcmid+"&DEVICE_FLAG=A";
    NSString *server = @"http://211.253.9.3:8080/";
    NSString *pageUrl = @"DWFMS";
    NSString *urlParam = [NSString stringWithFormat:@"?HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",@"11111111",@"22222222"];
    
    
    
    NSString *callUrl = [NSString stringWithFormat:@"%@%@%@",server,pageUrl,urlParam];
                         
    
    
    NSLog(callUrl);
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSURLRequest *requestURL=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestURL];

   
}

@end
