//
//  ViewController.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "ViewController.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
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
      [self.webView setDelegate:self];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    NSLog(@"static???start");
    GlobalData *glodate = [GlobalDataManager getgData];
    NSLog(@"--?? %@",glodate);
    [glodate setCompCd:(@"ddd")];
    NSLog(@"static???start1 %@",[glodate compCd]);
    CallServer *res = [CallServer alloc];
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    [param setValue:@"ffffffff" forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"loginByPhon.do" VAL:param];

    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSLog(str);
    NSString *urlParam=@"";
    NSString *server = @"http://211.253.9.3:8080/";
    NSString *pageUrl = @"DWFMS";
    /*
     자동로그인 부분
    */
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
        {
           
            
        }else{
            
             urlParam = [NSString stringWithFormat:@"?HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,@"22222222"];
            
        }
            
    }
    
    
    
    //callUrl=callUrl+"?HP_TEL="+PhoneNumber+"&GCM_ID="+gcmid+"&DEVICE_FLAG=A";
    
   
    
    
    
    NSString *callUrl = [NSString stringWithFormat:@"%@%@%@",server,pageUrl,urlParam];
                         
    
    
    NSLog(callUrl);
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSURLRequest *requestURL=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestURL];

   
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //javascript => document.location = "somelink://yourApp/form_Submitted:param1:param2:param3";
    //scheme : somelink
    //absoluteString : somelink://yourApp/form_Submitted:param1:param2:param3
    
    NSString *requesturl1 = [[request URL] scheme];
    if([@"toapp" isEqual:requesturl1])
    {
        NSString *requesturl2 = [[request URL] absoluteString];
        NSString *decoded = [requesturl2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray* list = [decoded componentsSeparatedByString:@":"];
        NSString *type  = [list objectAtIndex:1];
        NSLog(@"?? %@",type);
        if([@"login" isEqual:type])
        {
            
            [self login:[decoded substringFromIndex:([type length]+7)]];
        }
    }

    
    
    
    return YES;
}
//Error시 실행
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"IDI FAIL");
}

//WebView 시작시 실행
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"START LOAD");
}

//WebView 종료 시행
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"FNISH LOAD");
}

//script => app funtion
-(void) login:(NSString*) data{
    NSError *error;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setObject:@"-" forKey:@"INTIME"];
    [param setObject:@"-" forKey:@"OUTTIME"];
    [param setObject:@"박종훈" forKey:@"EMPNM"];
   
    
//     NSString *jsonInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"saltfactory",@"name",@"saltfactory@gmail.com",@"e-mail", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
        return;
    }
    
    NSString* searchWord = @"\"";
    NSString* replaceWord = @"";
//   jsonString =  [jsonString stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
   

    jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     NSLog(@"jsonString => %@", jsonString);
    
    NSString *escaped = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"escaped string :\n%@", escaped);
    
    searchWord = @"%20";
    replaceWord = @"";
    escaped =  [escaped stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @"%0A";
    replaceWord = @"";
    escaped =  [escaped stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];

    
    NSString *decoded = [escaped stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"decoded string :\n%@", decoded);
    
    NSString *scriptString = [NSString stringWithFormat:@"welcome(\"%@\");",escaped];
      NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];

}

@end
