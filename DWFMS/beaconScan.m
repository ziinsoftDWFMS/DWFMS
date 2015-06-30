//
//  beaconScan.m
//  DWFMS
//
//  Created by 김향기 on 2015. 6. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "beaconScan.h"


@implementation beaconScan



-(void) setupScan {
    NSDictionary * opts = nil;
    self.txPworList = [NSMutableDictionary new];
     if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
    {
        opts = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
    }
    
     self.central = [[KBCentralManager alloc] initWithQueue:nil options:opts];
    
  
    
    if (self.central.state != CBCentralManagerStatePoweredOn) {
        self.central.onStateChanged = ^(NSError * error){
            [self.central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}  onUpdated:^(KBPeripheral *peripheral) {
                
                
//                peripheral.peripheral
                
//
                NSString* macadd = peripheral.macAddress;
                NSArray * keys = [self.txPworList allKeys];
                
                if([keys containsObject:macadd])
                {
                    NSLog(@"??? %@ ",peripheral.RSSI);
                    [self calDistance:peripheral RSSI:peripheral.RSSI];
                    
                }
                else
                {
                    [self.central connectPeripheral:peripheral options:nil completion:^(KBPeripheral *peripheral, NSError *error) {
//                        NSLog(@"??con %@",peripheral.services);
                        [self getbeaconinfo:peripheral];
                        
                    } ondisconnected:^(KBPeripheral *peripheral, NSError *error) {
                        // NSLog(@"??dicon");
                    }];

                }

            }];
        };
        
    }
}

- (void)getbeaconinfo:(KBPeripheral *) beacon {
    
    
    NSLog(@"service %@",beacon.peripheral);
    
    [beacon discoverServices:nil completion:^(NSError *error) {
        NSLog(@"service %@",beacon.services);
        
        self.services = beacon.services;
        self.serviceDict =[NSMutableDictionary new];
        for (CBService *_service in self.services) {
            NSLog(@"?zzz %@ ",_service)   ;
            [beacon discoverCharacteristics:nil forService:_service onFinish:^(CBService *service, NSError *error) {
                NSLog(@"ll");
                if (_service == service) {
                    for (CBCharacteristic *characterstic in service.characteristics) {
                        [beacon readValueForCharacteristic:characterstic onFinish:^(Characterics *characterstics, unsigned long serviceCount) {
                            [self.serviceDict setObject:characterstics forKey:characterstics.uuid];
                            if (serviceCount == 1) {
                                //
                                //                                CBCharacteristic * ch = [self.serviceDict valueForKey:@"TX Power Level"];
                               
                                
                                [self.txPworList setObject:[[self.serviceDict valueForKey:@"Measured Power"] valuekey] forKey:beacon.macAddress];
                                
                                [self.central cancelPeripheralConnection:beacon completion:^(KBPeripheral *peripheral, NSError *error) {
                                    
                                }];
                                
                            }
                        }];
                    }
                }
            }];
        }
        
    }];
    
    
}

-(double)calDistance:(KBPeripheral *)tempBeacone RSSI:(NSNumber *) tempRssi{
    
     NSString * mac = tempBeacone.macAddress;
    int rssi = [tempRssi integerValue];
    NSLog(@" %@ : %d :%@", mac ,  rssi , [self.txPworList valueForKey:mac]);
    if(rssi < -1){
        NSLog(@"pp")  ;
    }
    
    return 0.1;
}
   
   
   

-(void) startScan:(AppDelegate *) ap{
    self.app = ap;
    [self setupScan];
    
}

@end
