//
//  Characterics.h
//  iOS-Kibeacon-Sample
//
//  Created by thenopen on 2014. 12. 9..
//  Copyright (c) 2014년 thenopen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Characterics : NSObject
@property (nonatomic, strong) NSString* uuid;
@property (nonatomic, strong) NSString* property;
@property (nonatomic, strong) NSString* valuekey;
@property (nonatomic, strong) NSString* asscii;
@property (nonatomic, strong) CBCharacteristic* characteristic;

+(NSInteger) eghitBitHexTosignedInt:(NSString *)hex;

@end