//
//  PredictionsFetcher.m
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "PredictionsFetcher.h"

@implementation PredictionsFetcher
{
    int _stopId;
}

- (id)initWithStopId:(int)stopId
{
    self = [super init];
    if(self) {
        _stopId = stopId;
    }
    
    return self;
}

- (void)addPredictions:(NSArray *)predictions
{
    [_delegate addPredictions:predictions];
}

- (void)fetchPredictions
{
    [_delegate startedFetching];
    self.predictions = [NSMutableArray array];
    
    // Download the data in a non blocking thread.
    NSString *feedURLString = @"http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r=L&useShortTitles=true&s=";
    
    feedURLString = [feedURLString stringByAppendingString: [NSString stringWithFormat:@"%i", _stopId]];
    
    NSURLRequest *predictionsUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    self.predictionsFeedConnection = [[NSURLConnection alloc] initWithRequest:predictionsUrlRequest delegate:self];
    
    // Test Connection
    NSAssert(self.predictionsFeedConnection != nil, @"Failure to create URL connection.");
    
    // Set the network spinner
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Check to make sure that the request was successful.
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if([httpResponse statusCode] / 100 == 2) {
        self.predictionsData = [NSMutableData data];
    } else {
        NSString * errorString = NSLocalizedString(@"HTTP Error", @"There was a connection error.");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.predictionsData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        NSString * errorString = NSLocalizedString(@"No Connection Error", @"Not connected to the internet.");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else {
        [self handleError:error];
    }
    
    [_delegate stoppedFetching];
    
    self.predictionsFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.predictionsFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    ParsePredictionsOperation *parsePredictionsOperation = [[ParsePredictionsOperation alloc] initWithData:self.predictionsData];
    [parsePredictionsOperation setDelegate:self];
    [self.parseQueue addOperation:parsePredictionsOperation];

    [_delegate stoppedFetching];
    self.predictionsData = nil;
}

- (void)handleError:(NSError *)error
{
    [_delegate errorOccured:[error localizedDescription]];
}

- (void)dealloc
{
    [_predictionsFeedConnection cancel];
}

- (void)errorOccured:(NSString *)errorMessage
{
    [_delegate errorOccured:errorMessage];
}

@end
