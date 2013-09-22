//
//  InboundVehicleAnnotation.m
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "InboundVehicleAnnotation.h"

@implementation InboundVehicleAnnotation
@synthesize title = _title;

- (void)setTitle:(NSString *)title
{
    _title = [title stringByAppendingString:@" - Inbound"];
}

@end
