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

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createMuniStops];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createMuniStops
{
    _inboundStops = [[NSMutableArray alloc] init];
    _outboundStops = [[NSMutableArray alloc] init];
    
    Stop *stop = [[Stop alloc] init];
    stop.stopId = 6637;
    stop.stopTitle = @"44th Ave & Taraval St";
    [_inboundStops addObject:stop];
    
    stop = [[Stop alloc] init];
    stop.stopId = 3599;
    stop.stopTitle = @"46th Ave & Taraval St";
    [_inboundStops addObject:stop];
    
    stop = [[Stop alloc] init];
    stop.stopId = 7217;
    stop.stopTitle = @"Embarcadero Station";
    [_outboundStops addObject:stop];
    
    stop = [[Stop alloc] init];
    stop.stopId = 6994;
    stop.stopTitle = @"Montgomery Station";
    [_outboundStops addObject:stop];
    
    stop = [[Stop alloc] init];
    stop.stopId = 6995;
    stop.stopTitle = @"Powell Station";
    [_outboundStops addObject:stop];
    
    stop = [[Stop alloc] init];
    stop.stopId = 6997;
    stop.stopTitle = @"Civic Center Station";
    [_outboundStops addObject:stop];
    
    stop = [[Stop alloc] init];
    stop.stopId = 6614;
    stop.stopTitle = @"17th Ave & Taraval St";
    [_outboundStops addObject:stop];
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
