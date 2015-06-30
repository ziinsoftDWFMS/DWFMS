//
//  beaconScan.h
//  DWFMS
//
//  Created by 김향기 on 2015. 6. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "KBCentralManager.h"
#import "KBPeripheral.h"
#import "Characterics.h"

@interface beaconScan : NSObject

@property(strong, nonatomic ) AppDelegate * app;
@property(strong , nonatomic) NSMutableDictionary * txPworList;
@property (nonatomic,strong) NSArray * services;
@property (nonatomic, strong) NSMutableDictionary *serviceDict;
@property (nonatomic,strong) KBCentralManager * central;
-(void) startScan:(AppDelegate *) ap;
- (void)getbeaconinfo:(KBPeripheral *) beacon;

@end
