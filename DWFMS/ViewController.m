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
#import "Commonutil.h"
#import "ZIINQRCodeReaderView.h"
#import "AppDelegate.h"
#import "ToastAlertView.h"
@interface ViewController ()

@end

@implementation ViewController{
    RECOBeaconManager *_recoManager;
    NSMutableDictionary *_rangedBeacon;
    NSMutableDictionary *_rangedRegions;
    NSArray *_uuidList;
    NSArray *_stateCategory;
    
}

NSString *viewType =@"LOGOUT";
NSString *beaconYN =@"Y";
NSString *bluetoothYN = @"N";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //if([self detectBluetooth] == TRUE){
    //    NSLog(@"bluetooth use");
    //    bluetoothYN = @"Y";
    //}else{
    //    NSLog(@"bluetooth unuse");
    //    bluetoothYN = @"N";
    //}
    // Do any additional setup after loading the view, typically from a nib.
    /// beacon uuid :[24DDF411-8CF1-440C-87CD-E368DAF9C93E]
    [GlobalData setbeacon:@"F"];
    
    [self setIsUpdateQr:NO];
    AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
    [ad setMain:self];
    
    //beaconstart
    _rangedBeacon = [[NSMutableDictionary alloc] init];
    _rangedRegions = [[NSMutableDictionary alloc] init];
    
    _recoManager = [[RECOBeaconManager alloc] init];
    _recoManager.delegate = self;
    [_recoManager requestAlwaysAuthorization];
    
    [ad startBackgroundMonitoring];
    
    for (RECOBeaconRegion *recoRegion in _rangedRegions) {
        [_recoManager startMonitoringForRegion:recoRegion];
        [_recoManager startRangingBeaconsInRegion:recoRegion];
    }
    
    
    //beacon end
    
    
    [self.webView setDelegate:self];
    
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
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
    NSString *server = [GlobalData getServerIp];
    NSString *pageUrl = @"/";
    NSString *callUrl = @"";
    /*
     자동로그인 부분
     */
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
        {
            NSDictionary *data = [jsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(data)];
            NSArray * timelist = [jsonInfo objectForKey:@"inout"];
            [GlobalDataManager setTime:[timelist objectAtIndex:0]];
            NSArray * authlist = [jsonInfo objectForKey:@"auth"];
            [GlobalDataManager initAuth:authlist];
            
            beaconYN = [data valueForKey:@"BEACON_YN"];
            NSMutableDictionary * session =[GlobalDataManager getAllData];
            
            [session setValue:[GlobalDataManager getAuth] forKey:@"auth"];
            [session setValue:[[GlobalDataManager getgData] inTime]  forKey:@"inTime"];
            [session setValue:[[GlobalDataManager getgData] outTime]  forKey:@"outTime"];
            
            urlParam = [Commonutil serializeJson:session];
            
            NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
            NSLog(@"urlParam %@",urlParam);
            callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
            
            
            if(![@"Y" isEqualToString:[data valueForKey:@"INFO_YN"]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:text delegate:self
                                                      cancelButtonTitle:@"취소"
                                                      otherButtonTitles:@"동의", nil];
                [alert show];
            }
            
            viewType = @"LOGIN";
            
            //_uuidList = [GlobalData sharedDefaults].supportedUUIDs;
            _uuidList = @[
                          [[NSUUID alloc] initWithUUIDString:[data valueForKey:@"BEACON_UUID"]]
                          //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                          // you can add other NSUUID instance here.
                          ];
            _stateCategory = @[@(RECOProximityUnknown),
                               @(RECOProximityImmediate),
                               @(RECOProximityNear),
                               @(RECOProximityFar)];
            
            [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                NSString *identifier = [NSString stringWithFormat:@"RECOBeaconRegion-%lu", (unsigned long)idx];
                
                [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
            }];
            NSLog(@"@@@@!!!!!!!!!!!!!!!!!!!!!!!!!@@@@@@@");
            [self startRanging];
            
        }else{
            
            urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,@"22222222"];
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
        }
        
    }
    
    
    
    
    
    NSLog(@"??callurl:%@",callUrl);
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
    [requestURL setHTTPMethod:@"POST"];
    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView loadRequest:requestURL];
    NSLog(@"??????? urlParam %@",urlParam);
    
    
    
}

- (BOOL)detectBluetooth
{
    if ([@"N"isEqual:beaconYN]) {
        return FALSE;
    }
    if(!self.blueToothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.blueToothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    [self centralManagerDidUpdateState:self.blueToothManager]; // Show initial state
    
    switch(self.blueToothManager.state)
    {
        case CBCentralManagerStateResetting: return FALSE; break;
        case CBCentralManagerStateUnsupported: return FALSE; break;
        case CBCentralManagerStateUnauthorized: return FALSE; break;
        case CBCentralManagerStatePoweredOff: return FALSE; break;
        case CBCentralManagerStatePoweredOn: return TRUE; break;
        default: return FALSE; break;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.blueToothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    NSLog(@"bluetoothstate :: %@", stateString);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startRanging];
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopRanging];
    
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
        
        //Webview : web call case
        
        if([@"login" isEqual:type])
        {
            
            [self login:[decoded substringFromIndex:([type length]+7)]];
            
        } else if ([@"QRun" isEqual:type]) {
            NSLog(@"QR START");
            [self detectBluetooth];
            [self setIsUpdateQr:NO];
            
            _qrView.hidden = NO;
            _qrView.isHiddenCam;
            NSLog(@"QR end");
            //[self performSegueWithIdentifier:@"callQRScan" sender:self];
        } else if ([@"updateQRun" isEqual:type]) {
            NSLog(@"updateQRun START");
            [self setIsUpdateQr:YES];
            
            _qrView.hidden = NO;
            _qrView.isHiddenCam;
            NSLog(@"updateQRun end");
            //[self performSegueWithIdentifier:@"callQRScan" sender:self];
        }else if([@"callImge" isEqual:type]){
            [self callImge:[decoded substringFromIndex:([type length]+7)]];
        } else if([@"logout" isEqual:type]){
            [self logout];
        } else if ([@"setSession" isEqual:type]) {
            
            NSMutableDictionary *reSession =[GlobalDataManager getAllData];
            [reSession setValue:[GlobalDataManager getAuth] forKey:@"auth"];
            [reSession setValue:[[GlobalDataManager getgData] inTime ]forKey:@"inTime"];
            [reSession setValue:[[GlobalDataManager getgData] outTime ]forKey:@"outTime"];
            
            NSString *scriptParameter = [NSString stringWithFormat:@"setsession('%@&reCall=%@');", [Commonutil serializeJson:reSession],[decoded substringFromIndex:([type length]+7)]];
            NSLog(@"setSession : call Script value : %@", scriptParameter);
            //json data return
            
            
            
            [webView stringByEvaluatingJavaScriptFromString:scriptParameter];
            
        } else if ([@"reCall" isEqual:type]) {
            NSString *scriptString = [NSString stringWithFormat:@"%@;", [decoded substringFromIndex:([type length]+7)]];
            NSLog(@"reCall : call Script value : %@", scriptString);
            
            [webView stringByEvaluatingJavaScriptFromString:scriptString];
        }else if([@"callbackwelcome"isEqual:type]) {
            
            [self callbackwelcome];
        }
    }
    
    
    return YES;
}
//개인정보동의 alert 창 callback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@";alert ?? %d",buttonIndex);
    if(buttonIndex ==1)
    {
        //
        CallServer *res = [CallServer alloc];
        
        
        NSMutableDictionary* param = [GlobalDataManager getAllData];
        
        
        
        NSString* str = [res stringWithUrl:@"invInfo.do" VAL:param];
    }else{
        exit(0);
    }
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
    
    NSLog(@"?logindata %@",data);
    NSData *sessionjsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *sessionjsonInfo = [NSJSONSerialization JSONObjectWithData:sessionjsonData options:kNilOptions error:&error];
    
    if(     [@"s"isEqual:[sessionjsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[sessionjsonInfo valueForKey:@"result"] ] )
        {
            viewType = @"LOGIN";
            NSDictionary *sessiondata = [sessionjsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(sessiondata)];
            NSArray * timelist = [sessionjsonInfo objectForKey:@"inout"];
            [GlobalDataManager setTime:[timelist objectAtIndex:0]];
            NSArray * authlist = [sessionjsonInfo objectForKey:@"auth"];
            [GlobalDataManager initAuth:authlist];
            beaconYN = [sessiondata valueForKey:@"BEACON_YN"];
            NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
            if(![@"Y" isEqualToString:[sessiondata valueForKey:@"INFO_YN"]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:text delegate:self
                                                      cancelButtonTitle:@"취소"
                                                      otherButtonTitles:@"동의", nil];
                [alert show];
            }
            
            NSLog(@"gcmid = %@",[[GlobalDataManager getgData] gcmId]);
            
            CallServer *res = [CallServer alloc];
            UIDevice *device = [UIDevice currentDevice];
            NSString* idForVendor = [device.identifierForVendor UUIDString];
            
            
            NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
            
            [param setValue:idForVendor forKey:@"HP_TEL"];
            [param setValue:[[GlobalDataManager getgData] gcmId] forKey:@"GCM_ID"];
            [param setObject:@"I" forKey:@"DEVICE_FLAG"];
            [param setObject:@"TEST" forKey:@"TEST"];
            
            //deviceId
            
            //R 수신
            
            NSString* str = [res stringWithUrl:@"registGCM.do" VAL:param];
            
            NSString *server = [GlobalData getServerIp];
            NSString *pageUrl = @"/";
            NSString *callUrl = @"";
            
            
            
            callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.webView loadRequest:requestURL];
            
            //_uuidList = [GlobalData sharedDefaults].supportedUUIDs;
            _uuidList = @[
                          [[NSUUID alloc] initWithUUIDString:[sessiondata valueForKey:@"BEACON_UUID"]]
                          //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                          // you can add other NSUUID instance here.
                          ];
            _stateCategory = @[@(RECOProximityUnknown),
                               @(RECOProximityImmediate),
                               @(RECOProximityNear),
                               @(RECOProximityFar)];
            
            [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                NSString *identifier = [NSString stringWithFormat:@"RECOBeaconRegion-%lu", (unsigned long)idx];
                
                [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
            }];
            NSLog(@"@@@@!!!!!!!!!!!!!!!!!!!!!!!!!@@@@@@@");
            [self startRanging];
            
        }else{
            
            
            [ToastAlertView showToastInParentView:self.view withText:@"아이디와 패스워드를 확인해주세요." withDuaration:3.0];
            
            
            
        }
    }else{
        
    }
    
    
    
}

-(void) callImge:(NSString*) data{
    NSLog(@"callimge??");
    NSArray* list = [data componentsSeparatedByString:@"&"];
    
    
    NSMutableDictionary * temp =[[NSMutableDictionary alloc] init];
    
    for(int i =0;i<[list count];i++){
        NSArray* listTemp =   [[list objectAtIndex:i] componentsSeparatedByString:@"="];
        [temp setValue:[listTemp objectAtIndex:1] forKey:[listTemp objectAtIndex:0]];
        
        NSLog(@" key %@  value %@ ",[listTemp objectAtIndex:0],[listTemp objectAtIndex:1]);
    }
    [[GlobalDataManager getgData]setCameraData:temp];
    
    [self performSegueWithIdentifier:@"CameraCall" sender:self];
}



- (void) setimage:(NSString*) path num:(NSString*)num{
    //       NSString * searchWord = @"/";
    //    NSString * replaceWord = @"\\\\";
    //    path =  [path stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    NSLog(@"ddd path %@ num %@",path,num);
    
    NSString *scriptString = [NSString stringWithFormat:@"setimge('%@','%@');",path,num];
    NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
}



- (void) setQRcode:(NSString*) data {
    //    request_contents.put("SERIAL_NO", SERIAL_NO);
    //    request_contents.put("url", "getQRJobTpy.do");
    NSLog(@"????? setQRcode data: %@",data);
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:data forKey:@"SERIAL_NO"];
    
    //deviceId
    
    //R 수신
    CallServer *res = [CallServer alloc];
    NSString* str = [res stringWithUrl:@"getQRJobTpy.do" VAL:param];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(@"?? %@",str);
    
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
        {
            NSDictionary *resdata = [jsonInfo valueForKey:(@"data")];
            
            if(  !   [[[GlobalDataManager getgData] compCd ]isEqual:[resdata valueForKey:@"COMP_CD"] ] )
            {
                //다른 사업장 업무입니다.
                //NSLog(@"다른사업장의 업무 입니다.");
                [ToastAlertView showToastInParentView:self.view withText:@"다른사업장의 업무 입니다." withDuaration:3.0];
                return;
            }
            
            if(     [@"00"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
            {
                [ToastAlertView showToastInParentView:self.view withText:@"QR업무를 등록해 주세요." withDuaration:3.0];
                NSString *pageUrl = @"/registrationQR.do";
                NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",ServerIp,pageUrl,data];
                
                NSLog(@"???????%@",callurl);
                NSURL *url=[NSURL URLWithString:callurl];
                
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                
                
                [self.webView loadRequest:requestURL];
                
                
                return;
                
            }
            
            if(     [self isUpdateQr] )
            {
                [ToastAlertView showToastInParentView:self.view withText:@"QR업무를 수정합니다." withDuaration:3.0];
                
                NSString *pageUrl = @"/registrationQR.do";
                NSString *callurl = [NSString stringWithFormat:@"%@%@?SERIAL_NO=%@",ServerIp,pageUrl,data];
                
                NSLog(@"???????%@",callurl);
                NSURL *url=[NSURL URLWithString:callurl];
                
                NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
                
                
                [self.webView loadRequest:requestURL];
                
                return;
                
            }
            
            if(     [@"01"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
            {
                [ToastAlertView showToastInParentView:self.view withText:@"보안순찰업무로 이동합니다." withDuaration:3.0];
                
                [self callPatrol:resdata];
            }
            
            if( [@"02"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
            {
                
                [self setInOutCommitInfo:resdata];
                
            }
            
            if( [@"03"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
            {
                
                [self setInOutCommitInfo:resdata];
            }
            if( [@"04"isEqual:[resdata valueForKey:@"JOB_TPY"] ] )
            {
                [ToastAlertView showToastInParentView:self.view withText:@"시설점검업무로 이동합니다." withDuaration:3.0];
                [self callChkWork:resdata];
            }
            
            
            
        }
        
    }
    
}

-(void) callPatrol:(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    NSString* str = [res stringWithUrl:@"PSTag.do" VAL:param];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(@"?? %@",str);
    
    NSArray * authlist = [[GlobalDataManager getgData] auth];
    
    
    NSLog(@" ?? %@ ",(  [authlist containsObject:@"fms653"] ? @"YES" : @"NO"));
    if(![authlist containsObject:@"fms653"]){
        //권한이 없습니다.
        return;
    }
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        NSString *server = [GlobalData getServerIp];
        
        
        NSArray * temparray = [jsonInfo valueForKey:(@"data")];
        NSDictionary *resdata = [temparray objectAtIndex:0];
        
        //mWebView.loadUrl(GlobalData.getServerIp()+"/patrolService.do?LOC_ID="+psdata.getString("PAT_LOC_ID")+"&PAT_CHECK_DT="+psdata.getString("sh_PAT_CHECK_DT")+"#detail");
        NSLog([resdata valueForKey:@"sh_PAT_CHECK_DT"]);
        NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
        [tempParam setValue:[resdata valueForKey:@"sh_PAT_CHECK_DT"] forKey:@"PAT_CHECK_DT"];
        [tempParam setValue:[resdata valueForKey:@"PAT_LOC_ID"] forKey:@"LOC_ID"];
        
        
        
        
        NSString *urlParam=[Commonutil serializeJson:tempParam];
        NSLog(@"??????? %@",urlParam);
        //NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/patrolService.do#detail";
        NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        //        NSString *pageUrl = @"/patrolService.do?";
        //        NSString *callurl = [NSString stringWithFormat:@"%@%@%@#detail",server,pageUrl,urlParam];
        NSLog(@"???????%@",callurl);
        NSURL *url=[NSURL URLWithString:callurl];
        
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [requestURL setHTTPMethod:@"POST"];
        [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
        [requestURL setHTTPShouldHandleCookies:NO];
        
        //"/patrolService.do?LOC_ID="+psdata.getString("PAT_LOC_ID")+"&PAT_CHECK_DT="+psdata.getString("sh_PAT_CHECK_DT")+"#detail"
        // /patrolService.do?PAT_CHECK_DT=2015-06-21 19:43:39.357&LOC_ID=85#detail
        //        http://211.253.9.3:8080/patrolService.do?PAT_CHECK_DT=2015-06-21 19:56:05.453&LOC_ID=85#detail
        //    [self.webView loadRequest:homeRequestURL];
        requestURL.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        NSString *currentURL = [[[self.webView request] URL] absoluteString];
        NSLog(@"???currentURL???%@",currentURL);
        
        if ([currentURL rangeOfString:@"patrolService"].location == NSNotFound) {
            [self.webView loadRequest:requestURL];
            NSLog(@"string does not contain bla");
            
        } else {
            NSString *scriptParameter = [NSString stringWithFormat:
                                         @"viewDetailIos('%@','%@');",
                                         [resdata valueForKey:@"PAT_LOC_ID"] ,
                                         [resdata valueForKey:@"sh_PAT_CHECK_DT"]];
            NSLog(@"scriptString => %@", scriptParameter);
            
            [self.webView stringByEvaluatingJavaScriptFromString:scriptParameter];
            NSLog(@"string does contain bla");
            
        }
        //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:testURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0]];
        NSLog(@"???????%@",requestURL);
        
        
        
        
    }
    
    //
}



-(void) setInOutCommitInfo :(NSMutableDictionary * ) param{
    //
    NSLog(@"beaconstatus ::::::: %@, %@", [GlobalData getbeacon], beaconYN);
    
    if([self detectBluetooth] == TRUE){
        NSLog(@"bluetooth use");
        bluetoothYN = @"Y";
    }else{
        
        NSLog(@"bluetooth unuse");
        bluetoothYN = @"N";
    }
    
    NSLog(@"bluethooth YN 1 ::::%@", bluetoothYN);
    
    
    //if ([@"Y"isEqual:beaconYN] && [@"Y"isEqual:bluetoothYN]) {
    if ([@"Y"isEqual:beaconYN]) {
        if([@"F"isEqual:[GlobalData getbeacon]] || [@"N"isEqual:bluetoothYN]){
            NSLog(@"beacon access Fail~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            [ToastAlertView showToastInParentView:self.view withText:@"근무지를 벗어난 곳에서는 QR업무를 사용 하실 수 없습니다.\n[ 블루투스를 확인해 주세요 ]" withDuaration:3.0];
            return;
        }
    }
    
    
    CallServer *res = [CallServer alloc];
    
    
    NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
    
    [sessiondata addEntriesFromDictionary:param];
    
    NSLog(@"??? sessiondata ?? %@" ,sessiondata);
    NSString* str = [res stringWithUrl:@"setInOutCommitInfo.do" VAL:sessiondata];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    
    if(     [@"02"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
        [ToastAlertView showToastInParentView:self.view withText:@"출근이 정상적으로 등록되었습니다." withDuaration:3.0];
    } else if(     [@"03"isEqual:[sessiondata valueForKey:@"JOB_TPY"] ] ) {
        [ToastAlertView showToastInParentView:self.view withText:@"퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
    } else {
        [ToastAlertView showToastInParentView:self.view withText:@"출/퇴근이 정상적으로 등록되었습니다." withDuaration:3.0];
    }
    
    NSString *server = [GlobalData getServerIp];
    NSString *pageUrl = @"/";
    NSString *callUrl = @"";
    
    
    
    callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
    [self.webView loadRequest:requestURL];
    
}
-(void) callChkWork:(NSMutableDictionary * ) param{
    CallServer *res = [CallServer alloc];
    NSString* str = [res stringWithUrl:@"CHKWORKTag.do" VAL:param];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(@"?? %@",str);
    
    NSArray * authlist = [[GlobalDataManager getgData] auth];
    
    
    NSLog(@" ?? %@ ",(  [authlist containsObject:@"fms653"] ? @"YES" : @"NO"));
    if(![authlist containsObject:@"fms113"]){
        //권한이 없습니다.
        return;
    }
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        NSArray * temparray = [jsonInfo valueForKey:(@"data")];
        NSDictionary *resdata = [temparray objectAtIndex:0];
        
        //mWebView.loadUrl(GlobalData.getServerIp()+"/patrolService.do?LOC_ID="+psdata.getString("PAT_LOC_ID")+"&PAT_CHECK_DT="+psdata.getString("sh_PAT_CHECK_DT")+"#detail");
        NSLog([resdata valueForKey:@"sh_PAT_CHECK_DT"]);
        NSMutableDictionary * tempParam = [[NSMutableDictionary alloc] init];
        [tempParam setValue:[resdata valueForKey:@"sh_PAT_CHECK_DT"] forKey:@"PAT_CHECK_DT"];
        [tempParam setValue:[resdata valueForKey:@"PAT_LOC_ID"] forKey:@"LOC_ID"];
        
        
        
        
        NSString *urlParam=[Commonutil serializeJson:tempParam];
        NSLog(@"??????? %@",urlParam);
        NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/chkWorkService.do#detail";
        NSString *callurl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        NSURL *url=[NSURL URLWithString:callurl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [requestURL setHTTPMethod:@"POST"];
        [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
        //[self.webView loadRequest:requestURL];
        NSLog(@"???????");
        //
        
        NSString *currentURL = [[[self.webView request] URL] absoluteString];
        NSLog(@"???currentURL???%@",currentURL);
        
        if ([currentURL rangeOfString:@"chkWorkService"].location == NSNotFound) {
            [self.webView loadRequest:requestURL];
            NSLog(@"string does not contain bla");
            
        } else {
            NSString *scriptParameter = [NSString stringWithFormat:
                                         @"viewDetailIos('%@','%@', '');",
                                         [resdata valueForKey:@"PAT_LOC_ID"] ,
                                         [resdata valueForKey:@"sh_PAT_CHECK_DT"]];
            NSLog(@"scriptString => %@", scriptParameter);
            
            [self.webView stringByEvaluatingJavaScriptFromString:scriptParameter];
            NSLog(@"string does contain bla");
            
        }
        
        
    }
    
    //
}

-(void) callWelcome{
    NSError *error;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    if([@"" isEqualToString:[[GlobalDataManager getgData] inTime]])
    {
        [param setObject:@"-" forKey:@"INTIME"];
    }else{
        
        [param setObject:[[GlobalDataManager getgData] inTime]  forKey:@"INTIME"];
    }
    
    if([@"" isEqualToString:[[GlobalDataManager getgData] outTime]])
    {
        [param setObject:@"-" forKey:@"OUTTIME"];
    }else{
        [param setObject:[[GlobalDataManager getgData] outTime]  forKey:@"OUTTIME"];
        
    }
    
    
    [param setObject:[[GlobalDataManager getgData] empNm] forKey:@"EMPNM"];
    
    
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
    
    NSString *scriptString = [NSString stringWithFormat:@"welcome(%@);",decoded];
    NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
}

-(void) logout{
    viewType = @"LOGOUT";
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    NSString *server = [GlobalData getServerIp];
    NSString *pageUrl = @"/";
    NSString *callUrl = @"";
    NSString * urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,@"22222222"];
    
    
    
    
    callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
    [requestURL setHTTPMethod:@"POST"];
    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView loadRequest:requestURL];
    
}
-(void)callbackwelcome{
    if([viewType isEqualToString:@"LOGOUT"]){
        return;
    }
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
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
    
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
        {
            
            NSString * oldempon = [[GlobalDataManager getgData]empNo];
            NSDictionary *data = [jsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(data)];
            NSArray * timelist = [jsonInfo objectForKey:@"inout"];
            [GlobalDataManager setTime:[timelist objectAtIndex:0]];
            NSArray * authlist = [jsonInfo objectForKey:@"auth"];
            [GlobalDataManager initAuth:authlist];
            beaconYN = [data valueForKey:@"BEACON_YN"];
            
            if(![oldempon isEqualToString:[[GlobalDataManager getgData] empNo] ]){
                [self logout];
            }
            else{
                [self callWelcome];
            }
            
            
            
            
        }
        else{
            [ToastAlertView showToastInParentView:self.view withText:@"다른폰에서 로그인 되었습니다.." withDuaration:3.0];
            [self logout];
        }
    }
}


- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)identifier {
    RECOBeaconRegion *recoRegion = [[RECOBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    
    _rangedRegions[recoRegion] = [NSArray array];
}
- (void) startRanging {
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~StartRanging~~~~~");
    if (![RECOBeaconManager isRangingAvailable]) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~return : not not not not isRangingAvailable");
        return;
    }
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~");
    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
        [_recoManager startRangingBeaconsInRegion:recoRegion];
    }];
}

- (void) stopRanging; {
    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
        [_recoManager stopRangingBeaconsInRegion:recoRegion];
    }];
}

#pragma mark - RECOBeaconManager delegate methods

- (void)recoManager:(RECOBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(RECOBeaconRegion *)region {
    NSLog(@"didRangeBeaconsInRegion: %@, ranged %lu beacons", region.identifier, (unsigned long)[beacons count]);
    
    if((unsigned long)[beacons count] > 0){
        [GlobalData setbeacon:@"T"];
    }
    
    _rangedRegions[region] = beacons;
    [_rangedBeacon removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    NSArray *arrayOfBeaconsInRange = [_rangedRegions allValues];
    [arrayOfBeaconsInRange enumerateObjectsUsingBlock:^(NSArray *beaconsInRange, NSUInteger idx, BOOL *stop){
        [allBeacons addObjectsFromArray:beaconsInRange];
    }];
    
    [_stateCategory enumerateObjectsUsingBlock:^(NSNumber *range, NSUInteger idx, BOOL *stop){
        NSArray *beaconsInRange = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        
        if ([beaconsInRange count]) {
            _rangedBeacon[range] = beaconsInRange;
        }
    }];
    //[self.tableView reloadData];
}

- (void)recoManager:(RECOBeaconManager *)manager rangingDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
    [GlobalData setbeacon:@"F"];
}

- (void) rcvAspn:(NSString*) jsonstring {
    NSLog(@"nslog");
    NSData *jsonData = [jsonstring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    NSString *msg = [jsonInfo valueForKey:@"MESSAGE"];
    NSString *title = [jsonInfo valueForKey:@"TITLE"];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
    
    
    if(     [@"AS"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        //mWebView.loadUrl(GlobalData.getServerIp()+"/DWFMSASDetail.do?JOB_CD="+gcmIntent.getStringExtra("JOB_CD")+"&GYULJAE_YN=N&sh_DEPT_CD="+ gcmIntent.getStringExtra("DEPT_CD")+"&sh_JOB_JISI_DT="+ gcmIntent.getStringExtra("JOB_JISI_DT"));
        
        
        
        if([GlobalDataManager hasAuth:@"fms113"]){
            NSLog(@"권한 없음");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"권한 없음" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alert show];
            return ;
        }
        
        if([ [[GlobalDataManager getgData] compCd] isEqual:[jsonInfo valueForKey:@"TASK_CD"] ]){
            NSLog(@"로그인한 사업장이 다릅니다 ");
            return;
        }
        
        if ([[jsonInfo valueForKey:@"TASK_CD"] isEqual: @"AIR"]) {
            NSDateFormatter *today = [[NSDateFormatter alloc] init];
            
            [today setDateFormat:@"yyyy-MM-dd"];
            NSString *nowDate = [today stringFromDate:[NSDate date]];
            
            [today setDateFormat:@"hh:mm"];
            NSString *time = [today stringFromDate:[NSDate date]];
            
            NSString *fullWccd = [jsonInfo valueForKey:@"JOB_TPY"];
            NSString *jobTpy = [fullWccd substringWithRange:NSMakeRange(2, 4) ];
            NSString *wccd = [fullWccd substringWithRange:NSMakeRange(0, 2) ];
            NSString *deptWccd = [jsonInfo valueForKey:@"WORK_CLASS_CD"];
            NSString *jobCd = [jsonInfo valueForKey:@"JOB_CD"];
            NSString *deptCd = [jsonInfo valueForKey:@"DEPT_CD"];
            
            NSLog(@"@@@@@@@@@ JOB_TPY %@", jobTpy);
            NSLog(@"@@@@@@@@@ WORK_CLASS_CD %@", deptWccd);
            
            NSLog(@"@@@@@@@@@@@@@@ WORK_CLASS_CD : /asManagementP1%@.do?req_JOB_CD=%@&req_GYULJAE_YN=N&req_txt_schDate=%@&req_selDEPT_CD=%@&req_selWORK_CLASS=%@&req_selWORK_CLASS1=%@&req_selWORK_CLASS2=%@&req_txt_schTime=%@", jobTpy, jobCd, nowDate, deptCd, deptWccd, wccd, fullWccd, time);
            
            NSString *server = [GlobalData getServerIp];
            NSString *pageUrl =  [NSString stringWithFormat:@"/asManagementP1%@.do",jobTpy];
            NSString *callUrl = @"";
            NSString * urlParam = [NSString stringWithFormat:@"req_JOB_CD=%@&req_GYULJAE_YN=N&req_txt_schDate=%@&req_selDEPT_CD=%@&req_selWORK_CLASS=%@&req_selWORK_CLASS1=%@&req_selWORK_CLASS2=%@&req_txt_schTime=%@", jobCd, nowDate, deptCd, deptWccd, wccd, fullWccd, time];
            
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [requestURL setHTTPMethod:@"POST"];
            [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
            [self.webView loadRequest:requestURL];
            
            
        }else{
            NSString *server = [GlobalData getServerIp];
            NSString *pageUrl = @"/DWFMSASDetail.do";
            NSString *callUrl = @"";
            NSString * urlParam = [NSString stringWithFormat:@"JOB_CD=%@&sh_DEPT_CD=%@&sh_JOB_JISI_DT=%@&GYULJAE_YN=N",[jsonInfo valueForKey:@"JOB_CD"],[jsonInfo valueForKey:@"DEPT_CD"],[jsonInfo valueForKey:@"JOB_JISI_DT"]];
            
            
            
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [requestURL setHTTPMethod:@"POST"];
            [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
            [self.webView loadRequest:requestURL];
        }
        
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
        [self.webView loadRequest:requestURL];
    }
    
    if(     [@"AS_RES"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
    {
        NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/afterService.do";
        NSString *callUrl = @"";
        
        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [self.webView loadRequest:requestURL];
        
    }
}

#pragma mark RECOBeaconManager delegate methods
- (void) recoManager:(RECOBeaconManager *)manager didDetermineState:(RECOBeaconRegionState)state forRegion:(RECOBeaconRegion *)region {
    NSLog(@"didDetermineState(background) %@", region.identifier);
}

- (void) recoManager:(RECOBeaconManager *)manager didEnterRegion:(RECOBeaconRegion *)region {
    NSLog(@"viewcontroller didEnterRegion(background) %@", region.identifier);
    [GlobalData setbeacon:@"T"];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // don't send any notifications
        NSLog(@"app active: not sending notification");
        return;
    }
    
    
    //  NSString *msg = [NSString stringWithFormat:@"didEnterRegion: %@", region.identifier];
    //  [self _sendEnterLocalNotificationWithMessage:msg];
}

- (void) recoManager:(RECOBeaconManager *)manager didExitRegion:(RECOBeaconRegion *)region {
    NSLog(@"viewcontroller didExitRegion(background) %@", region.identifier);
    [GlobalData setbeacon:@"F"];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // don't send any notifications
        NSLog(@"app active: not sending notification");
        return;
    }
    
    //NSString *msg = [NSString stringWithFormat:@"didExitRegion: %@", region.identifier];
    //[self _sendExitLocalNotificationWithMessage:msg];
}

- (void) recoManager:(RECOBeaconManager *)manager didStartMonitoringForRegion:(RECOBeaconRegion *)region {
    NSLog(@"didStartMonitoringForRegion(background) %@", region.identifier);
}

- (void) recoManager:(RECOBeaconManager *)manager monitoringDidFailForRegion:(RECOBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion(background) %@, error: %@", region.identifier, [error localizedDescription]);
}

@end
@implementation UIWebView (JavaScriptAlert)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
}



static BOOL diagStat = NO;
static NSInteger bIdx = -1;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:nil
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"취소"
                                                otherButtonTitles:@"확인", nil];
    
    [confirmDiag show];
    bIdx = -1;
    
    while (bIdx==-1) {
        //[NSThread sleepForTimeInterval:0.2];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    if (bIdx == 0){
        diagStat = NO;
    }
    else if (bIdx == 1) {
        diagStat = YES;
    }
    return diagStat;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    bIdx = buttonIndex;
}


@end
