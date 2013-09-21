//
//  MasterViewController.m
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Stop.h"

@interface MasterViewController () {
    NSMutableArray *_inboundStops;
    NSMutableArray *_outboundStops;
}
@end

@implementation MasterViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    [super viewWillAppear:animated];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createMuniStops];
}

- (void)createMuniStops
{
    _inboundStops = [[NSMutableArray alloc] initWithObjects:
                     [[Stop alloc] initWithData:@{@"stopId": @6637, @"stopTitle": @"44th Ave & Taraval St", @"latitude":@37.7418f, @"longitude": @-122.5026099f}],
                     [[Stop alloc] initWithData:@{@"stopId": @3599, @"stopTitle": @"46th Ave & Taraval St", @"latitude": @37.7416899f, @"longitude": @-122.5045299f}]
                     , nil];
    
    _outboundStops = [[NSMutableArray alloc] initWithObjects:
                      [[Stop alloc] initWithData:@{@"stopId": @7217, @"stopTitle": @"Embarcadero Station", @"latitude": @37.7932299f, @"longitude": @-122.39654f}],
                      [[Stop alloc] initWithData:@{@"stopId": @6994, @"stopTitle": @"Montgomery Station", @"latitude": @37.78879f, @"longitude": @-122.4021299f}],
                      [[Stop alloc] initWithData:@{@"stopId": @6995, @"stopTitle": @"Powell Station", @"latitude": @37.7843f, @"longitude": @-122.4078199f}],
                      [[Stop alloc] initWithData:@{@"stopId": @6997, @"stopTitle": @"Civic Center Station", @"latitude": @37.7786799f, @"longitude": @-122.41499f}],
                      [[Stop alloc] initWithData:@{@"stopId": @6614, @"stopTitle": @"17th Ave & Taraval St", @"latitude": @37.7432f, @"longitude": @-122.4734299f}]
                      , nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section) {
        case 0:
            return @"Inbound";
            break;
        
        case 1:
            return @"Outbound";
            break;
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section) {
        case 0:
            return _inboundStops.count;
            break;
            
        case 1:
            return _outboundStops.count;
            break;
    }
    
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Stop *object;
    
    switch(indexPath.section) {
        case 0:
            object = _inboundStops[indexPath.row];
            break;
            
        case 1:
            object = _outboundStops[indexPath.row];
            break;
    }
    
    cell.textLabel.text = [object stopTitle];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Stop *object;
        
        switch(indexPath.section) {
            case 0:
                object = _inboundStops[indexPath.row];
                break;
                
            case 1:
                object = _outboundStops[indexPath.row];
                break;
        }

        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
