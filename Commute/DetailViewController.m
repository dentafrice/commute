//
//  DetailViewController.m
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "DetailViewController.h"
#import "Stop.h"
#import "Prediction.h"

#define METERS_PER_MILE 1609.344

@interface DetailViewController ()
{
    UIBarButtonItem *_refreshItem;
}

- (void)configureView;

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
    self.predictions = [NSMutableArray array];
    [self setupToolbar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

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
        
        // MAP
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = [self.detailItem latitude];
        zoomLocation.longitude= [self.detailItem longitude];
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        
        [_mapView setRegion:viewRegion animated:YES];
        
        CLLocationCoordinate2D annotationCoord;
        
        annotationCoord.latitude = 47.640071;
        annotationCoord.longitude = -122.129598;
        
        MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
        annotationPoint.coordinate = zoomLocation;
        annotationPoint.title = [[self detailItem] stopTitle];
        [_mapView addAnnotation:annotationPoint];
    }
}

- (void)loadPredictions
{
    PredictionsFetcher *fetcher = [[PredictionsFetcher alloc] initWithStopId:[self.detailItem stopId]];
    [fetcher setDelegate:self];
    [fetcher fetchPredictions];
}

- (void)startedFetching
{
    [self.predictions removeAllObjects];
    self.detailDescriptionLabel.text = @"Loading..";
    [_refreshItem setEnabled:NO];
}

- (void)stoppedFetching
{
    [_refreshItem setEnabled:YES];
}

#pragma mark - NSUrlConnection Delegate Methods

- (void)predictionsError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    // noop? figure out some error handling.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - PredictionsFetcher delegate methods.

- (void)addPredictions:(NSArray *)predictions
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
