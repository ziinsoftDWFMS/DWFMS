//
//  KibeaconBlocks.h
//  iOS-Kibeacon-SDK
//
//  Created by thenopen on 2014. 10. 27..
//  Copyright (c) 2014년 KIES. All rights reserved.
//

#ifndef iOS_Kibeacon_SDK_KibeaconBlocks_h
#define iOS_Kibeacon_SDK_KibeaconBlocks_h

#import "Characterics.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@class KBPeripheral;
/// Object Status Changed
typedef void(^KBObjectChangedBlock)(NSError * error);
/// Peripheral Read RSS
typedef void(^KBPeripheralRSSIBlock)(NSError *error);
/// The Kibeacon Scan Service Status has Changed
typedef void(^KBPeripheralBlock)(KBPeripheral * peripheral);
/// The Kibeacon Connected
typedef void(^KBPeripheralConnectionBlock)(KBPeripheral * peripheral,NSError * error);
/// The Kibeacon Characteristic Read
typedef void(^KBCentralReadRequestBlock)(Characterics *dict, unsigned long serviceCount);
/// The Kibeacon Characteristic Write
typedef void(^KBCharacteristicChangedBlock)(CBCharacteristic * characteristic, NSError * error);
/// The Kibeacon Specify Service Updated
typedef void(^KBSpecifiedServiceUpdatedBlock)(CBService * service,NSError * error);

typedef void(^KBDidChangeAuthorizationStatus)  (CLAuthorizationStatus status);
typedef void(^KBDidRangeBeacons)  (NSArray *beacons, CLBeaconRegion *region);
typedef void(^KBDidUpdateRegion)  (BOOL isEnter, CLBeaconRegion *region);
typedef void(^KBDidEnterRegion)  (CLRegion *region);
typedef void(^KBDidExitRegion)  (CLRegion *region);
typedef void(^KBDidDetermineState)(CLRegion *region);
typedef void(^KBRangingBeaconsDidFailForRegion)  (CLBeaconRegion *region, NSError *error);
typedef void(^KBCheckLocationAccessForMonitoring)  (NSError *error);

#endif
