//
//  Stop.h
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stop : NSObject

- (id)initWithData:(NSDictionary *)data;

@property (nonatomic) int stopId;
@property (nonatomic) NSString *stopTitle;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end
