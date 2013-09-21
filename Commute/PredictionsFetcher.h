//
//  PredictionsFetcher.h
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParsePredictionsOperation.h"

@protocol PredictionsFetcherDelegate <NSObject>

- (void)addPredictions:(NSArray *)predictions;
- (void)startedFetching;
- (void)stoppedFetching;
- (void)errorOccured:(NSString *)errorMessage;

@end

@interface PredictionsFetcher : NSObject <ParsePredictionsOperationDelegate>

- (id)initWithStopId:(int)stopId;

@property (atomic) NSMutableArray *predictions;
@property (nonatomic) NSURLConnection *predictionsFeedConnection;
@property (nonatomic) NSMutableData *predictionsData;
@property (nonatomic) NSOperationQueue *parseQueue;
@property id<PredictionsFetcherDelegate> delegate;

- (void)fetchPredictions;
@end
