//
//  Stop.m
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "Stop.h"

@implementation Stop

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];

    if(self) {
        _isInbound = [[data valueForKey:@"isInbound"] boolValue];
        _stopId = [[data valueForKey:@"stopId"] intValue];
        _stopTitle = (NSString *)[data valueForKey:@"stopTitle"];
        _latitude = [[data valueForKey:@"latitude"] floatValue];
        _longitude = [[data valueForKey:@"longitude"] floatValue];
    }
    
    return self;
}

@end
