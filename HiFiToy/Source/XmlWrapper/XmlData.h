//
//  XmlData.h
//  iWoofer Pro
//
//  Created by Artem Khlyupin on 22/11/2017.
//  Copyright © 2017 Artem Khlyupin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlData : NSObject

- (void) clear;
- (void) addXmlData:(XmlData *) xmlData;

- (void) addElementWithName:(NSString *)name
               withXmlValue:(XmlData *)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level;
- (void) addElementWithName:(NSString *)name
            withStringValue:(NSString *)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level;
- (void) addElementWithName:(NSString *)name
               withIntValue:(int)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level;
- (void) addElementWithName:(NSString *)name
            withDoubleValue:(double)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level;
- (void) addElementWithName:(NSString *)name
              withBoolValue:(BOOL)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level;

//without length
- (void) addElementWithName:(NSString *)name withXmlValue:(XmlData *)value withAttrib:(NSDictionary *)attrib;
- (void) addElementWithName:(NSString *)name withStringValue:(NSString *)value withAttrib:(NSDictionary *)attrib;
- (void) addElementWithName:(NSString *)name withIntValue:(int)value withAttrib:(NSDictionary *)attrib;
- (void) addElementWithName:(NSString *)name withDoubleValue:(double)value withAttrib:(NSDictionary *)attrib;
- (void) addElementWithName:(NSString *)name withBoolValue:(BOOL)value withAttrib:(NSDictionary *)attrib;

//without level and attrib
- (void) addElementWithName:(NSString *)name withXmlValue:(XmlData *)value;
- (void) addElementWithName:(NSString *)name withStringValue:(NSString *)value;
- (void) addElementWithName:(NSString *)name withIntValue:(int)value;
- (void) addElementWithName:(NSString *)name withDoubleValue:(double)value;
- (void) addElementWithName:(NSString *)name withBoolValue:(BOOL)value;

- (void) setXmlHeader:(NSString *)header;
- (NSData *) toNSData;
    
@end
