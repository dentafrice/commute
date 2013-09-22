//
//  VehicleLocationFetcher.h
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseVehiclesOperation.h"

@protocol VehicleLocationFetcherDelegate <NSObject>
- (void)vehiclesFetched:(NSArray *)vehicles;
@end

@interface VehicleLocationFetcher : NSObject <ParseVehiclesOperationDelegate>

- (id)initWithRoute:(NSString *)route;
- (void)fetchVehicleLocations;

@property id<VehicleLocationFetcherDelegate> delegate;
@property (nonatomic) NSURLConnection *feedConnection;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSOperationQueue *parseQueue;

@end
