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

@class KBPeripheral;


@interface KBCentralManager : NSObject
@property (atomic,strong,readonly) NSMutableArray * peripherals;
@property(readonly) CBCentralManagerState state;
@property (nonatomic,copy) KBObjectChangedBlock onStateChanged;
/*!
 * Initialize Kibeeacon with queue and option.
 *
 */

- (instancetype) initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *) options NS_AVAILABLE(NA, 7_0);
- (instancetype) initWithQueue:(dispatch_queue_t)queue;

/*!
 * Starts scanning for peripherals that are advertising any of the services listed in serviceUUIDs.
 *  @param serviceUUIDs     A list of CBUUID objects representing the service to scan for.
 *  @param options          An optional dictionary specifying options for the scan.
 *  @param onUpdate         The callback block
 */
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(KBPeripheralBlock) onUpdate;
/*!
 * Stopping scan for Peripherals
 */
- (void)stopScan;

/*!
 * Initiates a connection to peripheral.
 *  @param peripheral       The Kibeacon to be connected.
 *  @param options          An optional dictionary specifying connection behavior options.
 *  @param finished         The callback block when connected to peripheral
 *  @param disconnected     The callback block
 */
- (void)connectPeripheral:(KBPeripheral *)peripheral options:(NSDictionary *)options completion:(KBPeripheralConnectionBlock) completion ondisconnected:(KBPeripheralConnectionBlock) disconnected;

/*!
 * Cancels an active or pending connection to peripheral.
 *  @param peripheral       Kibeacon of Peripherals
 *  @param ondisconnected   The callback block
 */
- (void)cancelPeripheralConnection:(KBPeripheral *)peripheral completion:(KBPeripheralConnectionBlock) ondisconnected;

@end
