//
//  ParseOperation.h
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

extern NSString *kAddPredictionsNotificationName;
extern NSString *kPredictionResultsKey;

extern NSString *kPredictionsErrorNotificationName;
extern NSString *kPredictionsMessageErrorKey;

#import <Foundation/Foundation.h>

@interface ParseOperation : NSOperation

@property (copy, readonly) NSData *predictionsData;

- (id)initWithData:(NSData *)parseData;

@end
