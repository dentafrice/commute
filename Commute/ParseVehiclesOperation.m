//
//  ParseVehiclesOperation.m
//  Commute
//
//  Created by Caleb Mingle on 9/21/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "ParseVehiclesOperation.h"
#import "Vehicle.h"

@implementation ParseVehiclesOperation
{
    Vehicle *_currentVehicleObject;
    NSMutableArray *_currentParseBatch;
}

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    
    if(self)
    {
        _data = parseData;
        _currentParseBatch = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)main
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.data];
    [parser setDelegate:self];
    [parser parse];
}

- (void)sendVehiclesToDelegate:(NSArray *)vehicles
{
    assert([NSThread isMainThread]);
    [_delegate vehiclesReceived:vehicles];
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"vehicle"]) {
        _currentVehicleObject = [[Vehicle alloc] init];
        [_currentVehicleObject setVId:[(NSString *)[attributeDict valueForKey:@"id"] intValue]];
        [_currentVehicleObject setSecondsSinceReport:[(NSString *)[attributeDict valueForKey:@"secsSinceReport"] intValue]];
        [_currentVehicleObject setLatitude:[(NSString *)[attributeDict valueForKey:@"lat"] floatValue]];
        [_currentVehicleObject setLongitude:[(NSString *)[attributeDict valueForKey:@"lon"] floatValue]];
        [_currentVehicleObject setHeading:[(NSString *)[attributeDict valueForKey:@"heading"] intValue]];
        [_currentVehicleObject setSpeed:[(NSString *)[attributeDict valueForKey:@"speedKmHr"] intValue]];
        
        NSString *dirTag = (NSString *)[attributeDict valueForKey:@"dirTag"];
        NSString *regEx = @".*IB.*";
        
        NSPredicate *regExTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
        
        if ([regExTest evaluateWithObject:dirTag] == YES) {
            [_currentVehicleObject setIsInbound:YES];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"vehicle"]) {
        [_currentParseBatch addObject:_currentVehicleObject];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self performSelectorOnMainThread:@selector(sendVehiclesToDelegate:) withObject:_currentParseBatch waitUntilDone:YES];
}


- (void)handleVehiclesError:(NSError *)error
{
    assert([NSThread isMainThread]);
    [_delegate errorOccured:[error localizedDescription]];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleVehiclesError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
