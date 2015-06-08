//
//  AppDelegate.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "AppDelegate.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        NSLog(@"%@",@"등록완료");
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        NSLog(@"%@",@"등록완료");
    }
    
    if(launchOptions)
    {
        NSLog(@" launchOptions %@ ",launchOptions);
        
       
        [[self main] viewDidLoad];
        
        sleep(1);
        
        CallServer *res = [CallServer alloc];
        UIDevice *device = [UIDevice currentDevice];
        NSString* idForVendor = [device.identifierForVendor UUIDString];
        
        
        NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
        
        [param setValue:idForVendor forKey:@"hp_tel"];
        
        //deviceId
        
        //R 수신
        
        
        NSString* str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
        
        
        NSLog(@"gcmmessage %@ ",str);
        
        [self  rcvAspnA:str];
        
    }
        
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSLog(@"My token is: %@", deviceToken);
    
//    obj.put("GCM_ID", gcmId);
//    obj.put("HP_TEL", mobileNo);
//    obj.put("DEVICE_FLAG", "A");
//    obj.put("TEST", "이인재입니다.");
//    JSONObject resObj = new ServletRequester("registGCM.do").execute(obj).get();
    

    
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    
    NSLog(@"APNS Device Token: %@", deviceId);
    // deviceTok = deviceId;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.DEVICE_TOK = deviceId;
    
    [[GlobalDataManager getgData] setGcmId:app.DEVICE_TOK];
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    [param setValue:app.DEVICE_TOK forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    [param setObject:@"TEST" forKey:@"TEST"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"registGCM.do" VAL:param];
    
    NSLog(@"APNS Device Tok: %@", app.DEVICE_TOK);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@" recive aspn %@ ",userInfo);
    
    if(application.applicationState == UIApplicationStateActive){
        NSString *sndPath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav" inDirectory:@"/"];
        CFURLRef sndURL = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:sndPath]);
        AudioServicesCreateSystemSoundID(sndURL, &ssid);
        
        AudioServicesPlaySystemSound(ssid);
        
    }
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"hp_tel"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
   
    NSLog(@"gcmmessage %@ ",str);
    [[self main] rcvAspn:str];
    
}
- (void) rcvAspnA:(NSString*) jsonstring {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:jsonstring delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
    NSLog(@"nslog");
    NSData *jsonData = [jsonstring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    
   
    
    if(     [@"AS"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        //mWebView.loadUrl(GlobalData.getServerIp()+"/DWFMSASDetail.do?JOB_CD="+gcmIntent.getStringExtra("JOB_CD")+"&GYULJAE_YN=N&sh_DEPT_CD="+ gcmIntent.getStringExtra("DEPT_CD")+"&sh_JOB_JISI_DT="+ gcmIntent.getStringExtra("JOB_JISI_DT"));
        sleep(1000);
        
        if([GlobalDataManager hasAuth:@"fms113"]){
            NSLog(@"권한 없음1");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"권한 없음1" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alert show];
            return ;
        }
        
        if([ [[GlobalDataManager getgData] compCd] isEqual:[jsonInfo valueForKey:@"TASK_CD"] ]){
            NSLog(@"로그인한 사업장이 다릅니다 ");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"로그인한 사업장이 다릅니다 " delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alert show];
            return;
        }
        NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/DWFMSASDetail.do";
        NSString *callUrl = @"";
        NSString * urlParam = [NSString stringWithFormat:@"JOB_CD=%@&sh_DEPT_CD=%@&sh_JOB_JISI_DT=%@&GYULJAE_YN=N",[jsonInfo valueForKey:@"JOB_CD"],[jsonInfo valueForKey:@"DEPT_CD"],[jsonInfo valueForKey:@"JOB_JISI_DT"]];
        
        
        
        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        UIAlertView *alert3 = [[UIAlertView alloc] initWithTitle:nil message:@"callUrl " delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alert3 show];
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [requestURL setHTTPMethod:@"POST"];
        [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
        [self.main.webView loadRequest:requestURL];
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:nil message:@"loadRequest " delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alert1 show];
    }
    
    if(     [@"NOTIFY"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        
        CallServer *res = [CallServer alloc];
        
        
        NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
        
        [sessiondata setValue:[jsonInfo valueForKey:@"COMP_CD"] forKey:@"comp_cd"];
        [sessiondata setValue:[[GlobalDataManager getgData] empNo] forKey:@"empno"];
        [sessiondata setValue:[jsonInfo valueForKey:@"COMMUTE_TYPE"] forKey:@"type"];
        
        NSLog(@"??? sessiondata ?? %@" ,sessiondata);
        NSString* str = [res stringWithUrl:@"confirmNoti.do" VAL:sessiondata];
        
        
        if([GlobalDataManager hasAuth:@"fms114"]){
            NSLog(@"권한 없음");
            return ;
        }
        NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/beforeService.do";
        NSString *callUrl = @"";
        
        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [self.main.webView loadRequest:requestURL];
    }
    
    if(     [@"AS_RES"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/afterService.do";
        NSString *callUrl = @"";
        
        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [self.main.webView loadRequest:requestURL];
        
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
