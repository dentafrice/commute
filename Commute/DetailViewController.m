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
#import "Vehicle.h"
#import "StationAnnotation.h"
#import "InboundVehicleAnnotation.h"
#import "OutboundVehicleAnnotation.h"

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
    self.vehicles = [NSMutableArray array];
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
        
        [_mapView setDelegate:self];
        [_mapView setRegion:viewRegion animated:YES];
        [self drawStationAnnotation];
    }
}

- (void)drawStationAnnotation
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.detailItem latitude];
    zoomLocation.longitude= [self.detailItem longitude];
    
    StationAnnotation *annotationPoint = [[StationAnnotation alloc] init];
    annotationPoint.coordinate = zoomLocation;
    annotationPoint.title = [[self detailItem] stopTitle];
    annotationPoint.subtitle = @"Stop";
    [_mapView addAnnotation:annotationPoint];
}

- (void)loadPredictions
{
    [_mapView removeAnnotations:_mapView.annotations];
    [self drawStationAnnotation];
    PredictionsFetcher *fetcher = [[PredictionsFetcher alloc] initWithStopId:[self.detailItem stopId]];
    [fetcher setDelegate:self];
    [fetcher fetchPredictions];
}

- (void)loadVehicles
{
    VehicleLocationFetcher *fetcher = [[VehicleLocationFetcher alloc] initWithRoute:@"L"];
    [fetcher setDelegate:self];
    [fetcher fetchVehicleLocations];
}

- (void)startedFetchingPredictions
{
    [self.predictions removeAllObjects];
    [self.detailDescriptionLabel setText:@"Loading.."];
    [_refreshItem setEnabled:NO];
}

- (void)stoppedFetchingPredictions
{
    [_refreshItem setEnabled:YES];
}

- (void)errorOccuredFetchingPredictions:(id)errorMessage
{
    NSString *alertTitle = NSLocalizedString(@"Predictions Error", @"Predictions Error.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMessage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
    
    [self.detailDescriptionLabel setText:@"Error Occured"];
}

- (void)errorOccured
{
    NSLog(@"error");
}

- (void)vehiclesFetched:(NSArray *)vehicles
{
    self.vehicles = [vehicles copy];
    NSMutableDictionary *lookupTable = [[NSMutableDictionary alloc] init];
    
    for(Vehicle *vehicle in self.vehicles) {
        [lookupTable setValue:vehicle forKey:[[NSNumber numberWithInt:[vehicle vId]] stringValue]];
    }
    
    for(Prediction *prediction in self.predictions) {
        Vehicle *vehicle = [lookupTable valueForKey:[[NSNumber numberWithInt:[prediction vehicle]] stringValue]];
        
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [vehicle latitude];
        annotationCoord.longitude = [vehicle longitude];
        
        MKPointAnnotation *annotationPoint;
        
        if([vehicle isInbound]) {
            annotationPoint = [[InboundVehicleAnnotation alloc] init];
        } else {
            annotationPoint = [[OutboundVehicleAnnotation alloc] init];
        }
    
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.title = [[NSNumber numberWithInt:[vehicle vId]] stringValue];
        annotationPoint.subtitle = [NSString stringWithFormat:@"%i minutes", [prediction minutes]];
        [_mapView addAnnotation:annotationPoint];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotationPoint
{
    static NSString *annotationIdentifier = @"annotationIdentifier";
    
    if([annotationPoint isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotationPoint reuseIdentifier:annotationIdentifier];
    
    if([annotationPoint isKindOfClass:[InboundVehicleAnnotation class]]) {
        pinView.pinColor = MKPinAnnotationColorGreen;
    } else if([annotationPoint isKindOfClass:[OutboundVehicleAnnotation class]]) {
        pinView.pinColor = MKPinAnnotationColorRed;
    } else {
        pinView.pinColor = MKPinAnnotationColorPurple;
    }
    
    pinView.canShowCallout = YES;
    
    return pinView;
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
    
    if([times count] > 0) {
        [self loadVehicles];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
