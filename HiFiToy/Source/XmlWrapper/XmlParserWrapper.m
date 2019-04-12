//
//  XmlParserWrapper.m
//  iWoofer Pro
//
//  Created by Artem Khlyupin on 23/11/2017.
//  Copyright © 2017 Artem Khlyupin. All rights reserved.
//

#import "XmlParserWrapper.h"

@interface XmlParserWrapper() {
    NSXMLParser * xmlParser;
    NSMutableArray * delegateStack;
    NSString * _elementName;

}

@end

@implementation XmlParserWrapper

- (id) init {
    if (self = [super init]){
        delegateStack = [[NSMutableArray alloc] init];
        _elementName = nil;
        _error = nil;
    }
    return self;
}

- (void)startParsingWithDelegate:(id)delegate {
    [delegateStack removeAllObjects];
    [self pushDelegate:delegate];
    
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    
    _error = nil;
    [xmlParser parse];
    
    NSError * e = [xmlParser parserError];
    if (e) {
        NSLog(@"%@", e.localizedDescription);
    }
}

- (void)startParsingWithUrl:(NSURL *)url withDelegate:(id)delegate {
    xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [self startParsingWithDelegate:delegate];
}

- (void)startParsingWithData:(NSData *)data withDelegate:(id)delegate {
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    [self startParsingWithDelegate:delegate];
}

- (void)stop {
    if (xmlParser){
        [xmlParser abortParsing];
    }
}

- (void)pushDelegate:(id)delegate {
    [delegateStack addObject:delegate];
}

- (void)popDelegate {
    [delegateStack removeLastObject];
}

/* -------------------------------------- NSXmlParserDelegete ---------------------------------------*/
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parser did end document.");
    
    id <XmlParserDelegate> delegate = [delegateStack lastObject];
    if (delegate){
        [delegate finishedParsing:_error];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
    
    _elementName = elementName;
    
    id <XmlParserDelegate> delegate = [delegateStack lastObject];
    if (delegate){
        [delegate didFindXmlElement:elementName
                         attributes:attributeDict
                             parser:self];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    id <XmlParserDelegate> delegate = [delegateStack lastObject];
    if (delegate){
        [delegate didFoundXmlCharacters:string forElement:_elementName parser:self];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    
    _elementName = nil;
    
    id <XmlParserDelegate> delegate = [delegateStack lastObject];
    if (delegate){
        [delegate didEndXmlElement:elementName parser:self];
    }
}


@end
