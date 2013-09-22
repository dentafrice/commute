//
//  Vehicle.h
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vehicle : NSObject

@property (nonatomic) int vId;
@property (nonatomic) int secondsSinceReport;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) int speed;
@property (nonatomic) int heading;
@property (nonatomic) BOOL isInbound;

@end
