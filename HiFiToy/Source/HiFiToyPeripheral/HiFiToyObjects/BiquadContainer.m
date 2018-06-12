//
//  BiquadContainer.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BiquadContainer.h"

@interface BiquadContainer() {
    NSMutableArray * biquads;
    int count;
}

@end

@implementation BiquadContainer

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:biquads forKey:@"keyBiquads"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        biquads = [decoder decodeObjectForKey:@"keyBiquads"];
    }
    return self;
}


/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(BiquadContainer *)copyWithZone:(NSZone *)zone
{
    BiquadContainer * copyBiquadContainer = [[[self class] allocWithZone:zone] init];
    
    //copyBiquadContainer.biquads = [[NSMutableArray alloc] initWithArray:self.biquads copyItems:YES];
    for (int i = 0; i < [self count]; i++) {
        [copyBiquadContainer addBiquad:[[self biquadAtIndex:i] copy]];
    }
    
    return copyBiquadContainer;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        BiquadContainer * temp = object;
        
        if ((!biquads) && (!temp)){
            return YES;
        } else if ((!biquads) || (!temp)) {
            return NO;
        }
        
        if ([self count] == [temp count]) {
            for (int i = 0; i < [self count]; i++) {
                
                if (![[self biquadAtIndex:i] isEqual:[temp biquadAtIndex:i]]) {
                    return NO;
                }
            }
            return YES;
        }
    }
    
    return NO;
}

//getter setters
- (int) count
{
    if (biquads) {
        return (int)[biquads count];
    }

    return -1;
}

- (void) addBiquad:(Biquad *)biquad
{
    if (!biquads){
        biquads = [[NSMutableArray alloc] init];
    }
    
    [biquads addObject:biquad];
}

- (Biquad * ) biquadAtIndex:(NSUInteger)index
{
    if (biquads) {
        return [biquads objectAtIndex:index];
    }
    return nil;
}

- (void) clear
{
    if (biquads) {
        [biquads removeAllObjects];
    }
}

/*- (void) setBiquadContainer:(BiquadContainer *) biquadContainer
{
    
    if ((!self.biquads) || (self.biquads.count == 0)){
        return;
    } else {
        for (int i = 0; i < self.biquads.count; i++){
            Biquad * biquadSrc = [biquadContainer.biquads objectAtIndex:i];
            Biquad * biquadDest = [self.biquads objectAtIndex:i];
            
            if (biquadSrc){
                [biquadDest setBiquad:biquadSrc];
            }
        }
    }
    
}*/

//Enabled methods
- (void) setEnabled:(BOOL)enabled
{
    if (enabled) { // set YES
        for (int i = 0; i < [self count]; i++){
            Biquad * biquad = [self biquadAtIndex:i];
            
            if (fabs(biquad.dbVolume) > 0.01){
                biquad.type = BIQUAD_PARAMETRIC;
                [biquad sendWithResponse:YES];
            }
        }
    } else { //set NO
        for (int i = 0; i < [self count]; i++){
            Biquad * biquad = [self biquadAtIndex:i];
            
            if ((biquad.type != BIQUAD_DISABLED) && (fabs(biquad.dbVolume) > 0.01)){
                biquad.type = BIQUAD_DISABLED;
                [biquad sendWithResponse:YES];
            } else {
                biquad.type = BIQUAD_DISABLED;
            }
        }
        
    }
    
    
}

- (BOOL) isEnabled
{
    for (int i = 0; i < [self count]; i++){
        Biquad * biquad = [self biquadAtIndex:i];
        
        if (biquad.type != BIQUAD_DISABLED){
            return YES;
        }
    }
    return NO;
}

- (BOOL) isActive
{
    for (int i = 0; i < [self count]; i++){
        Biquad * biquad = [self biquadAtIndex:i];
        
        if ((biquad.type != BIQUAD_DISABLED) && (fabs(biquad.dbVolume) > 0.01)){
            return YES;
        }
    }
    return NO;
}


//HiFiToy Object
- (uint8_t)address {
    return [self biquadAtIndex:0].address;
}

//info string
-(NSString *) getInfo
{
    if ((!biquads) || ([self count]  == 0)){
        return @"Empty";
    } else {
        return [NSString stringWithFormat:@"BiquadContainer length=%d", [self count] ];
    }
    
    return @"Empty";
}

//send to dsp
- (void)sendWithResponse:(BOOL)response
{
    if ((!biquads) || ([self count] == 0)){
        return;
    } else {
        for (int i = 0; i < [self count]; i++){
            Biquad * biquad = [self biquadAtIndex:i];
            
            [biquad sendWithResponse:response];
        }
    }
    
}


- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    for (int i = 0; i < [self count]; i++){
        Biquad * biquad = [self biquadAtIndex:i];
        [data appendData:[biquad getBinary]];
    }
    
    return data;
}

- (BOOL)importData:(NSData *)data
{
    if ((!biquads) || ([self count] == 0)){
        return YES;
    } else {
        for (int i = 0; i < [self count]; i++){
            Biquad * biquad = [self biquadAtIndex:i];
            
            if ([biquad importData:data] == NO){
                return NO;
            }
        }
    }
    
    return YES;
}

/*---------------------------- XML export/import ----------------------------------*/
- (XmlData *)toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    for (int i = 0; i < [self count]; i++){
        [xmlData addXmlData:[[self biquadAtIndex:i] toXmlData]];
        
    }
    
    XmlData * biquadContainerXmlData = [[XmlData alloc] init];
    
    int dspAddr = [self biquadAtIndex:0].address;
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:dspAddr] stringValue], @"Address", nil];
    
    [biquadContainerXmlData addElementWithName:@"BiquadContainer" withXmlValue:xmlData withAttrib:dict];
    
    return biquadContainerXmlData;
}

- (void)importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *,NSString *> *)attributeDict {
    count = 0;
    [xmlParser pushDelegate:self];
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void)didFindXmlElement:(NSString *)elementName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict parser:(XmlParserWrapper *)xmlParser {
    //get DspAddress of DspBiquad
    NSString * addrStr = [attributeDict objectForKey:@"Address"];
    if (!addrStr) return;
    int dspAddr = [addrStr intValue];
    
    for (int i = 0; i < [self count]; i++){
        Biquad * biquad = [self biquadAtIndex:i];
        if (dspAddr == biquad.address){
            [biquad importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
    }
}

- (void)didFoundXmlCharacters:(NSString *)characters forElement:(NSString *)elementName parser:(XmlParserWrapper *)xmlParser {

}

- (void)didEndXmlElement:(NSString *)elementName parser:(XmlParserWrapper *)xmlParser {
    if ([elementName isEqualToString:@"BiquadContainer"]){
        if (count != [self count]){
            xmlParser.error = @"BiquadContainer. Import from xml is not success.";
        }
        [xmlParser popDelegate];
    }
}

@end
