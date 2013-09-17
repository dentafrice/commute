//
//  DetailViewController.m
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "DetailViewController.h"
#import "Stop.h"
#import "ParseOperation.h"

@interface DetailViewController ()
- (void)configureView;

@property (nonatomic) NSMutableArray *predictions;
@property (nonatomic) NSURLConnection *predictionsFeedConnection;
@property (nonatomic) NSMutableData *predictionsData;
@property (nonatomic) NSOperationQueue *parseQueue;

@end

@implementation DetailViewController

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    [self setupNetworkConnection];
}

- (void)configureView
{
    if (self.detailItem) {
        self.navigationItem.title = [self.detailItem stopTitle];
        self.detailDescriptionLabel.text = @"Loading..";
    }
}

- (void)setupNetworkConnection
{
    self.predictions = [NSMutableArray array];
    
    // Download the data in a non blocking thread.
    NSString *feedURLString = @"http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r=L&useShortTitles=true&s=";
    
    feedURLString = [feedURLString stringByAppendingString: [NSString stringWithFormat:@"%i", [self.detailItem stopId]]];
    
    NSURLRequest *predictionsUrlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    self.predictionsFeedConnection = [[NSURLConnection alloc] initWithRequest:predictionsUrlRequest delegate:self];
    
    // Test Connection
    NSAssert(self.predictionsFeedConnection != nil, @"Failure to create URL connection.");
    
    // Set the network spinner
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPredictions:) name:kAddPredictionsNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(predictionsError:) name:kPredictionsErrorNotificationName object:nil];
}

#pragma mark - NSUrlConnection Delegate Methods

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
        // If we can identify the error, we present a suitable message to the user.
        NSString * errorString = NSLocalizedString(@"No Connection Error", @"Not connected to the internet.");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else {
        // Otherwise handle the error generically.
        [self handleError:error];
    }
    
    self.predictionsFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.predictionsFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Spawn an NSOperation to parse the data so that the UI is not blocked.
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithData:self.predictionsData];
    [self.parseQueue addOperation:parseOperation];

    // The NSOperation maintains a strong reference to the predictionsData until it has finished executing so we no longer need a reference to the data in the main thread
    self.predictionsData = nil;
}

- (void)handleError:(NSError *)error {
    
    NSString *errorMessage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Parse Error", @"Parse error.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMessage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
}

- (void)addPredictions:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    [self addPredictionsToList:[[notif userInfo] valueForKey:kPredictionResultsKey]];
}

- (void)predictionsError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    [self handleError:[[notif userInfo] valueForKey:kPredictionsMessageErrorKey]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// The NSOperation "ParseOperation" calls addPredictions: via NSNotification, on the main thread
// which in turn calls this method, with batches of parsed objects.  The batch size is set via the
// kSizeOfPredictionsBatch constant

- (void)addPredictionsToList:(NSArray *)predictions
{
    [self.predictions addObjectsFromArray:predictions];
    
    NSSortDescriptor *sortDescriptor;
    
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"minutes"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.predictions sortUsingDescriptors:sortDescriptors];
    
    self.detailDescriptionLabel.text = [[self.predictions valueForKey:@"minutes"] componentsJoinedByString:@", "];
}

- (void)dealloc
{
    [_predictionsFeedConnection cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPredictionsNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPredictionsErrorNotificationName object:nil];
}

@end
