//
//  ParsePredictionsOperation.m
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "ParsePredictionsOperation.h"
#import "Prediction.h"

@interface ParsePredictionsOperation () <NSXMLParserDelegate>

@property (nonatomic) Prediction *currentPredictionObject;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;

@end

@implementation ParsePredictionsOperation

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    
    if(self) {
        _predictionsData = [parseData copy];
        _currentParseBatch = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)sendPredictionsToDelegate:(NSArray *)predictions
{
    assert([NSThread isMainThread]);
    [_delegate addPredictions:predictions];
}

// main function to start parsing
- (void)main {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.predictionsData];
    [parser setDelegate:self];
    [parser parse];
}

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"prediction"]) {
        Prediction *prediction = [[Prediction alloc] init];
        self.currentPredictionObject = prediction;
        self.currentPredictionObject.minutes = [(NSString *)[attributeDict valueForKey:@"minutes"] intValue];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"prediction"]) {
        [self.currentParseBatch addObject:self.currentPredictionObject];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self performSelectorOnMainThread:@selector(sendPredictionsToDelegate:) withObject:self.currentParseBatch waitUntilDone:YES];
}

- (void)handlePredictionsError:(NSError *)error
{
    assert([NSThread isMainThread]);
    [_delegate errorOccured:[error localizedDescription]];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handlePredictionsError:) withObject:parseError waitUntilDone:NO];
    }
}

@end

