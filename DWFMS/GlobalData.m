//
//  GlobalData.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData


- (id)init {
    self = [super init];
//    if(self) {
//        // this is RECO beacon uuid
//        _supportedUUIDs = @[
//                            [[NSUUID alloc] initWithUUIDString:@"24DDF411-8CF1-440C-87CD-E368DAF9C93E"]
//                            //24DDF411-8CF1-440C-87CD-E368DAF9C93E
//                            // you can add other NSUUID instance here.
//                            ];
//
//    }
    return self;
}

//@synthesize compCd;
+(NSString*) getServerIp{
    return ServerIp;
}

+(NSString*) getHomedir{
    return homedir;
}


    +(void) setbeacon:(NSString*) tfvalue{
        beaconTF = tfvalue;
    }


+(NSString*) getbeacon{
    return beaconTF;
}

+ (GlobalData *)sharedDefaults {
    static id sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[self alloc] init];
    });
    
    return sharedDefaults;
}
@end
