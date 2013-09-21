//
//  DetailViewController.h
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import "PredictionsFetcher.h"

@interface DetailViewController : UIViewController <PredictionsFetcherDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic) NSMutableArray *predictions;

@end
