//
//  XmlData.m
//  iWoofer Pro
//
//  Created by Artem Khlyupin on 22/11/2017.
//  Copyright © 2017 Artem Khlyupin. All rights reserved.
//

#import "XmlData.h"

@interface XmlData (){
    NSString * _header;
    NSMutableArray * stringArr;
}
@end

@implementation XmlData

- (id) init {
    if ( self = [super init]){
        _header = @"\n";//@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        stringArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int) count {
    return (int)stringArr.count;
}

- (void) clear {
    [stringArr removeAllObjects];
}

- (void) addString:(NSString *)str {
    [stringArr addObject:str];
}

- (void) addXmlData:(XmlData *) xmlData {
    if (!xmlData) return;
    
    for (int i = 0; i < [xmlData count]; i++){
        [self addString:[xmlData getAtIndex:i]];
    }
}

- (NSString *) getAtIndex:(int)index {
    return [stringArr objectAtIndex:index];
}

- (void) addElementWithName:(NSString *)name
               withXmlValue:(XmlData *)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level{
    NSString * levelStr = [self getLevelStr:level];
    NSString * levelValueStr = [self getLevelStr:level + 1];
    NSString * attribStr = [self getAttribStr:attrib];
    
    if (attribStr.length > 0){
        if (value){
            [self addString:[NSString stringWithFormat:@"%@<%@ %@>\n", levelStr, name, attribStr]];
        } else {
            [self addString:[NSString stringWithFormat:@"%@<%@ %@/>\n", levelStr, name, attribStr]];
            return;
        }
    } else {
        if (value){
            [self addString:[NSString stringWithFormat:@"%@<%@>\n", levelStr, name]];
        } else {
            [self addString:[NSString stringWithFormat:@"%@<%@/>\n", levelStr, name]];
            return;
        }
    }
    
    //add value strings
    for (int i = 0; i < [value count]; i++){
        NSString * str = [value getAtIndex:i];
        NSString * strWithLevel = [NSString stringWithFormat:@"%@%@", levelValueStr, str];
    
        [self addString:strWithLevel];
    }
    
    [self addString:[NSString stringWithFormat:@"%@</%@>\n", levelStr, name]];
    
}

- (void) addElementWithName:(NSString *)name
            withStringValue:(NSString *)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level{

    NSString * levelStr = [self getLevelStr:level];
    NSString * attribStr = [self getAttribStr:attrib];
    
    NSString * elementStr;
    if (attribStr.length > 0){
        elementStr = [NSString stringWithFormat:@"%@<%@ %@>%@</%@>\n", levelStr, name, attribStr, value, name];
    } else {
        elementStr = [NSString stringWithFormat:@"%@<%@>%@</%@>\n", levelStr, name, value, name];
    }
    
    [self addString:elementStr];
}

/*- (void) addElementWithName:(NSString *)name
            withStringValue:(NSString *)value
                  withLevel:(int)level{
    NSString * levelStr = [self getLevelStr:level];
    NSString * elementStr = [NSString stringWithFormat:@"%@<%@>%@</%@>\n", levelStr, name, value, name];
    
    [self addString:elementStr];
}*/

- (void) addElementWithName:(NSString *)name
               withIntValue:(int)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level {
    [self addElementWithName:name
             withStringValue:[NSString stringWithFormat:@"%d", value]
                  withAttrib:attrib
                   withLevel:level];
}

- (void) addElementWithName:(NSString *)name
            withDoubleValue:(double)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level {
    [self addElementWithName:name
             withStringValue:[NSString stringWithFormat:@"%0.9f", value]
                  withAttrib:attrib
                   withLevel:level];
}

- (void) addElementWithName:(NSString *)name
              withBoolValue:(BOOL)value
                 withAttrib:(NSDictionary *)attrib
                  withLevel:(int)level {
    [self addElementWithName:name
             withStringValue:[NSString stringWithFormat:@"%@", value ? @"true" : @"false"]
                  withAttrib:attrib
                   withLevel:level];
}

//without level
- (void) addElementWithName:(NSString *)name
               withXmlValue:(XmlData *)value
                 withAttrib:(NSDictionary *)attrib{
    [self addElementWithName:name withXmlValue:value withAttrib:attrib withLevel:0];
}
- (void) addElementWithName:(NSString *)name
            withStringValue:(NSString *)value
                 withAttrib:(NSDictionary *)attrib{
    [self addElementWithName:name withStringValue:value withAttrib:attrib withLevel:0];
}
- (void) addElementWithName:(NSString *)name
               withIntValue:(int)value
                 withAttrib:(NSDictionary *)attrib{
    [self addElementWithName:name withIntValue:value withAttrib:attrib withLevel:0];
}
- (void) addElementWithName:(NSString *)name
            withDoubleValue:(double)value
                 withAttrib:(NSDictionary *)attrib{
    [self addElementWithName:name withDoubleValue:value withAttrib:attrib withLevel:0];
}
- (void) addElementWithName:(NSString *)name
              withBoolValue:(BOOL)value
                 withAttrib:(NSDictionary *)attrib{
    [self addElementWithName:name withBoolValue:value withAttrib:attrib withLevel:0];
}

//without level and attrib
- (void) addElementWithName:(NSString *)name withXmlValue:(XmlData *)value {
    [self addElementWithName:name withXmlValue:value withAttrib:nil];
}
- (void) addElementWithName:(NSString *)name withStringValue:(NSString *)value {
    [self addElementWithName:name withStringValue:value withAttrib:nil];
}
- (void) addElementWithName:(NSString *)name withIntValue:(int)value {
    [self addElementWithName:name withIntValue:value withAttrib:nil];
}
- (void) addElementWithName:(NSString *)name withDoubleValue:(double)value {
    [self addElementWithName:name withDoubleValue:value withAttrib:nil];
}
- (void) addElementWithName:(NSString *)name withBoolValue:(BOOL)value {
    [self addElementWithName:name withBoolValue:value withAttrib:nil];
}


- (NSString *) getLevelStr:(int)level {
    NSString * levelStr = @"";
    
    for (int i = 0; i < level; i++){
        levelStr = [levelStr stringByAppendingString:@"\t"];
    }
    return levelStr;
}

- (NSString *) getAttribStr:(NSDictionary *)dict {
    NSString * attribStr = @"";
    
    if (!dict) return attribStr;
    
    for (int i = 0; i < [dict count]; i++){
        NSString * str = [NSString stringWithFormat:@"%@=\"%@\" ",
                          [dict.allKeys objectAtIndex:i],
                          [dict.allValues objectAtIndex:i]];
        
        attribStr = [attribStr stringByAppendingString:str];
    }
    return attribStr;
}

- (void) setXmlHeader:(NSString *)header {
    _header = header;
}

- (NSData *) toNSData {
    NSString * outputString = [_header copy];
    
    for (int i = 0; i < [self count]; i++){
        outputString = [outputString stringByAppendingString:[self getAtIndex:i]];
    }
    
    return [outputString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
