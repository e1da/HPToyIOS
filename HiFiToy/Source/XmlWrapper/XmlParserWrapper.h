//
//  XmlParserWrapper.h
//  iWoofer Pro
//
//  Created by Artem Khlyupin on 23/11/2017.
//  Copyright © 2017 Artem Khlyupin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlParserWrapper : NSObject <NSXMLParserDelegate>

@property (nonatomic) NSString * error;

- (void)startParsingWithUrl:(NSURL *)url withDelegate:(id)delegate;
- (void)startParsingWithData:(NSData *)data withDelegate:(id)delegate;
- (void)stop;
- (void)pushDelegate:(id)delegate;
- (void)popDelegate;

@end

@protocol XmlParserDelegate

- (void) didFindXmlElement:(NSString *)elementName
                attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
                    parser:(XmlParserWrapper *)xmlParser;

- (void) didFoundXmlCharacters:(NSString *)characters
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser;

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser;

@optional
- (void) finishedParsing:(NSString *)error;

@end
