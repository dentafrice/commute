//
//  ParsePredictionsOperation.h
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParsePredictionsOperationDelegate <NSObject>

- (void)addPredictions:(NSArray *)result;

@end

@interface ParsePredictionsOperation : NSOperation

@property (copy, readonly) NSData *predictionsData;
@property id<ParsePredictionsOperationDelegate> delegate;

- (id)initWithData:(NSData *)parseData;

@end
