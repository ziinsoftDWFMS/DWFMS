//
//  KibeaconBlocks.h
//  iOS-Kibeacon-SDK
//
//  Created by thenopen on 2014. 10. 27..
//  Copyright (c) 2014년 KIES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KibeaconBlocks.h"

@interface CBCharacteristic (Description)

/*!
 * Get characteristic reference by name
 *
 */

- (NSString*)characteristicName;

/*!
 * Retun HEX String from Characteristic
 *
 */

- (NSString*)hexString;

/*!
 * Retun ASCII String from Characteristic
 *
 */

- (NSString*)asciiString;
@end

@interface KBPeripheral : NSObject
@property (nonatomic,strong,readonly) CBPeripheral * peripheral;
@property (nonatomic) NSArray * services;
@property (nonatomic,strong) NSUUID *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *RSSI;
@property (readonly) CBPeripheralState state;
@property (nonatomic, strong) NSString *macAddress;
@property (nonatomic, strong) NSString *batteryLevel;
@property (nonatomic, strong) NSDictionary *advertisementData;

- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral;

/*!
 *  Discovers available services on the peripheral
 *
 *  @param serviceUUIDs         A list of CBUUID objects representing the service types to be discovered.
 *  @param discoverFinished           Callback block
 */

- (void)discoverServices:(NSArray *)serviceUUIDs completion:(KBObjectChangedBlock)discoverFinished;
/*!
 *  Discovers the specified characteristic(s) of service.
 *
 *  @param includedServiceUUIDs A list of CBUUID objects representing the included service types to be discovered.
 *  @param service				A GATT service.
 *  @param finished           Callback block
 */
- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service completion:(KBSpecifiedServiceUpdatedBlock) finished;

/*!
 *  While connected, retrieves the current RSSI of the link.
 *
*/
- (void)readRSSICompetion:(KBPeripheralRSSIBlock)completion;

/*!
 *  Discovers the specified characteristic(s) of service.
 *
 *  @param characteristicUUIDs	A list of CBUUID objects representing the characteristic types to be discovered.
 *  @param onfinish             Callback block
 */

- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service onFinish:(KBSpecifiedServiceUpdatedBlock) onfinish;

/*!
 *  Reads the characteristic value for characteristic.
 *
 *  @param characteristic       A GATT characteristic.
 *  @param onUpdate             Callback block
 */

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic onFinish:(KBCentralReadRequestBlock) onUpdate;

/*!
 *  Writes value to characteristic's characteristic value.
 *
 *  @param data				The value to write.
 *  @param characteristic	The characteristic whose characteristic value will be written.
 *  @param type				The type of write to be executed.
 *  @param onfinish         Thc callback block
 */

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type onFinish:(KBCharacteristicChangedBlock) onfinish;
@end
