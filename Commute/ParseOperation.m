//
//  ParseOperation.m
//  Commute
//
//  Created by Caleb Mingle on 9/16/13.
//  Copyright (c) 2013 Caleb Mingle. All rights reserved.
//

#import "ParseOperation.h"
#import "Prediction.h"

// NSNotification name for sending predictions data back to the app delegate
NSString *kAddPredictionsNotificationName = @"AddPredictionsNotif";

// NSNotification userInfo key for obtaining the predictions data
NSString *kPredictionResultsKey = @"PredictionResultsKey";

// NSNotification name for reporting errors
NSString *kPredictionsErrorNotificationName = @"PredictionErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kPredictionsMessageErrorKey = @"PredictionsMsgErrorKey";

@interface ParseOperation () <NSXMLParserDelegate>

@property (nonatomic) Prediction *currentPredictionObject;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;

@end

@implementation ParseOperation

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    
    if(self) {
        _predictionsData = [parseData copy];
        _currentParseBatch = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addPredictionsToList:(NSArray *)predictions
{
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddPredictionsNotificationName object:self userInfo:@{kPredictionResultsKey: predictions}];
}

// main function to start parsing
- (void)main {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.predictionsData];
    [parser setDelegate:self];
    [parser parse];
    
//    if([self.currentParseBatch count] > 0) {
//        [self performSelectorOnMainThread:@selector(addPredictionsToList:) withObject:self.currentParseBatch waitUntilDone:NO];
//    }
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
    [self performSelectorOnMainThread:@selector(addPredictionsToList:) withObject:self.currentParseBatch waitUntilDone:NO];
}

- (void)handlePredictionsError:(NSError *)parseError
{
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPredictionsErrorNotificationName object:self userInfo:@{kPredictionsMessageErrorKey: parseError}];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handlePredictionsError:) withObject:parseError waitUntilDone:NO];
    }
}

@end

