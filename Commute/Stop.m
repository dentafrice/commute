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
        _stopId = [[data valueForKey:@"stopId"] intValue];
        _stopTitle = (NSString *)[data valueForKey:@"stopTitle"];
    }
    
    return self;
}

@end
