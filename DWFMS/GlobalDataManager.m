//
//  GlobalDataManager.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 18..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "GlobalDataManager.h"

@implementation GlobalDataManager

+ (GlobalData*) getgData {
    
    NSLog(@"dddd?? %@",gData);
    
    if(gData == nil)
    {
     
        gData = [GlobalData alloc];
        
        NSLog(@"make??/?? %@",gData);
         return gData;
    }
    return gData;
}


@end
