//
//  CallServer.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 16..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "CallServer.h"
#import "GlobalDataManager.h"
#import "GlobalData.h"

@implementation CallServer



- (void) test:(NSString*) url{
    
    
    NSString *serverUrl = [NSString stringWithFormat:@"http://175.114.60.67:8090/%@",url] ;
    
    NSLog(@"callserver %@",serverUrl);
    
    //NSData* requestData = [serverUrl dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:serverUrl] ];
    //    [request setHTTPMethod: @"GET"];
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    //    [request setHTTPBody:requestData];
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    // This is how we set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
    
    
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData");
    
    NSLog(@"str = %@",str);
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    
    
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    
}

- (NSString *)stringWithUrl:(NSString *)url VAL:(NSMutableDictionary*)param
{
   
    
    NSString *serverUrl = [NSString stringWithFormat:@"%@/%@",ServerIp,url] ;
    
    NSLog(@"callserver %@",serverUrl);
    
    NSMutableURLRequest  *urlRequest = [NSMutableURLRequest  requestWithURL:[ NSURL URLWithString:serverUrl]
                                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                            timeoutInterval:30];
    
    NSArray* keys = param.allKeys;
    
    NSLog(@"keys cont %d",keys.count);
    
    NSString * urlParam =@"";
    for (int i=0; i<keys.count; i++) {
        urlParam = [NSString stringWithFormat:@"%@%@=%@&",urlParam,[keys objectAtIndex:i],[param objectForKey:[keys objectAtIndex:i]]];
        NSLog(@"key %@  value %@",[keys objectAtIndex:i],[param objectForKey:[keys objectAtIndex:i]] );
    }
    
    // This is how we set header fields
    [urlRequest setHTTPBody:[[NSString stringWithFormat:urlParam] dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPMethod:@"POST"];
    
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    
    NSLog(@"error :%@",error);
    // Construct a String around the Data from the response
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

@end
