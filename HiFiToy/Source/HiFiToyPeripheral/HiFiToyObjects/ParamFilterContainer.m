//
//  BiquadContainer.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "ParamFilterContainer.h"

@interface ParamFilterContainer() {
    NSMutableArray * params;
    int count;
}

@end

@implementation ParamFilterContainer

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:params forKey:@"keyParams"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        params = [decoder decodeObjectForKey:@"keyParams"];
    }
    return self;
}


/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(ParamFilterContainer *)copyWithZone:(NSZone *)zone
{
    ParamFilterContainer * copyBiquadContainer = [[[self class] allocWithZone:zone] init];
    
    //copyBiquadContainer.biquads = [[NSMutableArray alloc] initWithArray:self.biquads copyItems:YES];
    for (int i = 0; i < [self count]; i++) {
        [copyBiquadContainer addParam:[[self paramAtIndex:i] copy]];
    }
    
    return copyBiquadContainer;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ((object) && ([object class] == [self class])) {
        ParamFilterContainer * temp = object;
        
        if ([self count] == [temp count]) {
            for (int i = 0; i < [self count]; i++) {
                
                if (![[self paramAtIndex:i] isEqual:[temp paramAtIndex:i]]) {
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
    if (params) {
        return (int)[params count];
    }

    return -1;
}

- (void) addParam:(ParamFilter *)param
{
    if (!params){
        params = [[NSMutableArray alloc] init];
    }
    
    [params addObject:param];
}

- (ParamFilter *) paramAtIndex:(NSUInteger)index
{
    if (params) {
        return (ParamFilter *)[params objectAtIndex:index];
    }
    return nil;
}

- (ParamFilter *) paramWithMinFreq
{
    int index = 0;
    for (int i = 0; i < [self count]; i++) {
        ParamFilter * current = [self paramAtIndex:i];
        ParamFilter * min = [self paramAtIndex:index];
        
        if (min.freq > current.freq) {
            index = i;
        }
    }
    return [self paramAtIndex:index];
}

- (ParamFilter *) paramWithMaxFreq
{
    int index = 0;
    for (int i = 0; i < [self count]; i++) {
        ParamFilter * current = [self paramAtIndex:i];
        ParamFilter * max = [self paramAtIndex:index];
        
        if (max.freq < current.freq) {
            index = i;
        }
    }
    return [self paramAtIndex:index];
}

- (void) removeAtIndex:(NSUInteger)index
{
    if (params) {
        [params removeObjectAtIndex:index];
    }
}

- (void) removeParam:(ParamFilter *) param
{
    if ([self containsParam:param]) {
        NSUInteger index = [self indexOfParam:param];
        [self removeAtIndex:index];
    }
}

//try copy param to another disactive param and delete
- (void) removeWithPossibleReplace:(ParamFilter *) param
{
    if ((!param) || (![self containsParam:param])) return;
    
    if ([param isActive]) {
 
        for (int i = 0; i < [self count]; i++) {
            ParamFilter * p = [self paramAtIndex:i] ;
            if (p == param) continue;
            
            if (![p isActive]) {
                [p setBiquad:param];
                [p sendWithResponse:YES];
                break;
            }
        }
    }
    
    [self removeParam:param];
}

- (void) clear
{
    if (params) {
        [params removeAllObjects];
    }
}

- (BOOL) containsParam:(ParamFilter *) param
{
    return [params containsObject:param];
}

- (NSUInteger) indexOfParam:(ParamFilter *) param
{
    return [params indexOfObject:param];
}

- (ParamFilter *) findParamWithAddr:(int)addr
{
    for (int i = 0; i < [self count]; i++) {
        ParamFilter * param = [self paramAtIndex:i];
        
        if (param.address0 == addr) {
            return param;
        }
    }
    return nil;
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
            ParamFilter * param = [self paramAtIndex:i];
            
            //if (fabs(param.dbVolume) > 0.01){
                [param setEnabled:YES];
            //}
        }
    } else { //set NO
        for (int i = 0; i < [self count]; i++){
            ParamFilter * param = [self paramAtIndex:i];
            
            [param setEnabled:NO];
  
            /*if ((biquad.type != BIQUAD_DISABLED) && (fabs(biquad.dbVolume) > 0.01)){
                biquad.type = BIQUAD_DISABLED;
                [biquad sendWithResponse:YES];
            } else {
                biquad.type = BIQUAD_DISABLED;
            }*/
        }
        
    }
    
    
}

- (BOOL) isEnabled
{
    for (int i = 0; i < [self count]; i++){

        if ([[self paramAtIndex:i] isEnabled]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isActive
{
    for (int i = 0; i < [self count]; i++){
        
        if ([[self paramAtIndex:i] isActive]) {
            return YES;
        }
    }
    return NO;
}


//HiFiToy Object
- (uint8_t)address {
    return [self paramAtIndex:0].address;
}

//get AMPL FREQ response
- (double) getAFR:(double)freqX
{
    double resultAFR = 1.0;
    
    if (params) {
        for (int i = 0; i < [self count]; i++){
            resultAFR *= [[self paramAtIndex:i] getAFR:freqX];
        }
    }

    return resultAFR;
}

- (ParamFilter *) getFirstEnabled
{
    if (params) {
        for (int i = 0; i < [self count]; i++){
            if ([[self paramAtIndex:i] isEnabled]) {
                return [self paramAtIndex:i];
            }
        }
    }
    
    return nil;
}

- (ParamFilter *) getFirstDisabled
{
    if (params) {
        for (int i = 0; i < [self count]; i++){
            if (![[self paramAtIndex:i] isEnabled]) {
                return [self paramAtIndex:i];
            }
        }
    }
    
    return nil;
}

//sort params. first - active and last - dis active
- (void) sortActive
{
    if (params) {
        BOOL replaceFlag = YES;
        
        while (replaceFlag) {
            replaceFlag = NO;
            
            for (int i = 0; i < [self count] - 1; i++){
                ParamFilter * current = [[self paramAtIndex:i] copy];
                ParamFilter * next = [self paramAtIndex:i + 1];
                
                if ((![current isActive]) && ([next isActive])) {
                    //swap address
                    /*int addr0 = current.address0;
                    int addr1 = current.address0;
                    current.address0 = next.address0;
                    current.address1 = next.address1;
                    next.address0 = addr0;
                    next.address1 = addr1;*/
                    //swap params
                    [params replaceObjectAtIndex:i withObject:next];
                    [params replaceObjectAtIndex:(i + 1) withObject:current];
                    
                    replaceFlag = YES;
                    break;
                }
            }
        }
    }
}


//info string
-(NSString *) getInfo
{
    if ((params) && ([self count] > 0)){
        
        return [NSString stringWithFormat:@"BiquadContainer length=%d", [self count] ];
    }
    
    return @"Empty";
}

//send to dsp
- (void)sendWithResponse:(BOOL)response
{
    if (params) {
        for (int i = 0; i < [self count]; i++){
            [[self paramAtIndex:i] sendWithResponse:response];
        }
    }
    
}


- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    for (int i = 0; i < [self count]; i++){
        ParamFilter * param = [self paramAtIndex:i];
        [data appendData:[param getBinary]];
    }
    
    return data;
}

- (BOOL)importData:(NSData *)data
{
    if (params) {
        for (int i = 0; i < [self count]; i++){

            if ([[self paramAtIndex:i] importData:data] == NO){
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
        [xmlData addXmlData:[[self paramAtIndex:i] toXmlData]];
        
    }
    
    XmlData * biquadContainerXmlData = [[XmlData alloc] init];
    
    int dspAddr = [self paramAtIndex:0].address;
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
    NSString * addrStr = [attributeDict objectForKey:@"Address0"];
    if (!addrStr) return;
    int dspAddr = [addrStr intValue];
    
    for (int i = 0; i < [self count]; i++){
        Biquad * biquad = [self paramAtIndex:i];
        if (dspAddr == biquad.address0){
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
