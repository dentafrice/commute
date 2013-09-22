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
- (void)startedFetchingPredictions;
- (void)stoppedFetchingPredictions;
- (void)errorOccuredFetchingPredictions:(NSString *)errorMessage;

@end

@interface PredictionsFetcher : NSObject <ParsePredictionsOperationDelegate>

- (id)initWithStopId:(int)stopId;

@property (nonatomic) NSURLConnection *predictionsFeedConnection;
@property (nonatomic) NSMutableData *predictionsData;
@property (nonatomic) NSOperationQueue *parseQueue;
@property id<PredictionsFetcherDelegate> delegate;

- (void)fetchPredictions;
@end
