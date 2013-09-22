//
//  OutboundVehicleAnnotation.m
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "OutboundVehicleAnnotation.h"

@implementation OutboundVehicleAnnotation
@synthesize title = _title;

- (void)setTitle:(NSString *)title
{
    _title = [title stringByAppendingString:@" - Outbound"];
}

@end
