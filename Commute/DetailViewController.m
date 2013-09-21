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
#import "Prediction.h"

@interface DetailViewController ()
{
    UIBarButtonItem *_refreshItem;
}

- (void)configureView;

@property (nonatomic) NSMutableArray *predictions;
@property (nonatomic) NSURLConnection *predictionsFeedConnection;
@property (nonatomic) NSMutableData *predictionsData;
@property (nonatomic) NSOperationQueue *parseQueue;

@end

@implementation DetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupToolbar];
}

- (void)setupToolbar
{
    self.navigationController.toolbarHidden = YES;
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    _refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked:)];
    
    NSArray *items = [NSArray arrayWithObjects:flexible, _refreshItem, nil];
    self.toolbarItems = items;
    
    self.navigationController.toolbarHidden=NO;
}

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
    [self setupToolbar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPredictions:) name:kAddPredictionsNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(predictionsError:) name:kPredictionsErrorNotificationName object:nil];

    [self configureView];
    [self loadPredictions];
}

- (void)refreshClicked:(id)sender
{
    [self loadPredictions];
}

- (void)enteredForeground:(NSNotification *)notif
{
    [self loadPredictions];
}

- (void)configureView
{
    if (self.detailItem) {
        self.navigationItem.title = [self.detailItem stopTitle];
    }
}

- (void)loadPredictions
{
    [self.predictions removeAllObjects];
    self.predictionsData = nil;
    self.predictionsFeedConnection = nil;
    self.detailDescriptionLabel.text = @"Loading..";
    
    [self makeAPIRequest];
}

- (void)makeAPIRequest
{
    self.predictions = [NSMutableArray array];
    [_refreshItem setEnabled:NO];
    
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
    [_refreshItem setEnabled:YES];
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
    
    NSMutableArray *times = [[NSMutableArray alloc] init];
    
    for(Prediction *prediction in self.predictions) {
        NSString *timeString = ([prediction minutes] == 0) ? @"Now" : [NSString stringWithFormat:@"%i", [prediction minutes]];
        
        [times addObject:timeString];
    }
    

    self.detailDescriptionLabel.text = ([times count] > 0) ? [times componentsJoinedByString:@", "] : @"No Predictions";
}

- (void)dealloc
{
    [_predictionsFeedConnection cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPredictionsNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPredictionsErrorNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
