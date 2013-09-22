//
//  VehicleLocationFetcher.m
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "VehicleLocationFetcher.h"

@implementation VehicleLocationFetcher
{
    NSString *_route;
}

- (id)initWithRoute:(NSString *)route;
{
    self = [super init];
    
    if(self) {
        _route = route;
    }
    
    return self;
}

- (void) fetchVehicleLocations
{
    self.parseQueue = [NSOperationQueue new];
    
    NSString *feedURLString = @"http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni&r=";
    feedURLString = [feedURLString stringByAppendingString:_route];
    
    NSURLRequest *vehiclesUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    self.feedConnection = [[NSURLConnection alloc] initWithRequest:vehiclesUrlRequest delegate:self];
    
    NSAssert(self.feedConnection != nil, @"Failure to create URL connection.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)errorOccured:(NSString *)errorMessage
{
    
}

- (void)vehiclesReceived:(NSArray *)vehicles
{
    [_delegate vehiclesFetched:vehicles];
}

- (void)handleError:(NSError *)error
{
    // noop.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if([httpResponse statusCode] / 100 == 2) {
        self.data = [NSMutableData data];
    } else {
        NSString * errorString = NSLocalizedString(@"HTTP Error", @"There was a connection error.");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
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
    
    self.feedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.feedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    ParseVehiclesOperation *operation = [[ParseVehiclesOperation alloc] initWithData:self.data];
    
    [operation setDelegate:self];
    [self.parseQueue addOperation:operation];
    
    self.data = nil;
}

- (void)dealloc
{
    [_feedConnection cancel];
}

@end
