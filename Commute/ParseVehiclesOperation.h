//
//  ParseVehiclesOperation.h
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParseVehiclesOperationDelegate <NSObject>
- (void)errorOccured:(NSString *)message;
- (void)vehiclesReceived:(NSArray *)vehicles;
@end

@interface ParseVehiclesOperation : NSOperation <NSXMLParserDelegate>

@property (copy, readonly) NSData *data;
@property id<ParseVehiclesOperationDelegate> delegate;

- (id)initWithData:(NSData *)parseData;

@end