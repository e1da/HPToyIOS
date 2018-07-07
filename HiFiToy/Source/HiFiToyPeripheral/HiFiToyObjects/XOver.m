//
//  XOver.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 27/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "XOver.h"
#import "ParamFilter.h"

@interface XOver(){
    int count;
}
@end

@implementation XOver

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.address0 forKey:@"keyAddress0"];
    [encoder encodeInt:self.address1 forKey:@"keyAddress1"];
    
    [encoder encodeObject:self.params forKey:@"keyParams"];
    [encoder encodeObject:self.hp forKey:@"keyHP"];
    [encoder encodeObject:self.lp forKey:@"keyLP"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.address0 = [decoder decodeIntForKey:@"keyAddress0"];
        self.address1 = [decoder decodeIntForKey:@"keyAddress1"];
        
        self.params = [decoder decodeObjectForKey:@"keyParams"];
        self.hp = [decoder decodeObjectForKey:@"keyHP"];
        self.lp = [decoder decodeObjectForKey:@"keyLP"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(XOver *)copyWithZone:(NSZone *)zone
{
    XOver * copyXover = [[[self class] allocWithZone:zone] init];
    
    copyXover.address0 = self.address0;
    copyXover.address1 = self.address1;
    
    copyXover.params = (self.params) ? [self.params copy] : nil;
    copyXover.hp = (self.hp) ? [self.hp copy] : nil;
    copyXover.lp = (self.lp) ? [self.lp copy] : nil;
    
    return copyXover;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ((object) && ([object class] == [self class])) {
        XOver * temp = object;
        
        if ((self.address0 != temp.address0) ||
            (self.address1 != temp.address1)) {
            return NO;
        }
        
        if (self.params){
            if ([self.params isEqual:temp.params] == NO) {
                return NO;
            }
        } else if (temp.params) {
            return NO;
        }
        
        if (self.hp){
            if ([self.hp isEqual:temp.hp] == NO) {
                return NO;
            }
        } else if (temp.hp) {
            return NO;
        }
        
        if (self.lp){
            if ([self.lp isEqual:temp.lp] == NO) {
                return NO;
            }
        } else if (temp.lp) {
            return NO;
        }

        return YES;
    }
    return NO;
}

/*---------------------- create method -----------------------------*/
//stereo
+ (XOver *)initWithAddress0:(int)address0 Address1:(int)address1
                     Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp
{
    XOver *currentInstance = [[XOver alloc] init];
    
    currentInstance.address0 = address0;
    currentInstance.address1 = address1;
    
    currentInstance.params = params;
    currentInstance.hp = hp;
    currentInstance.lp = lp;
    
    [currentInstance update];
    
    return currentInstance;
}

//mono
+ (XOver *)initWithAddress:(int)address
                    Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp
{
    return [self initWithAddress0:address Address1:0 Params:params Hp:hp Lp:lp];
}

- (uint8_t)address {
    return self.address0;
    
}

/*typedef enum : uint8_t{
    HP0_LP0_PARAM7,
    HP0_LP1_PARAM6,
    HP0_LP2_PARAM5,
    HP1_LP0_PARAM6,
    HP1_LP1_PARAM5,
    HP1_LP2_PARAM4,
    HP2_LP0_PARAM5,
    HP2_LP1_PARAM4,
    HP2_LP2_PARAM3,
} XOverState_t;*/

//setters/getters
- (XOverState_t) getState
{
    XOverState_t state;
    
    if (self.hp) {
        state = self.hp.biquadLength * 3;//0..2
        if (state > HP2_LP0_PARAM5) return ERROR;
        
    } else {
        state = HP0_LP0_PARAM7;
    }
    
    if (self.lp) {
        if (self.lp.biquadLength > BIQUAD_LENGTH_2) return ERROR;
        state += self.lp.biquadLength;// +0..2
    }
    
    uint8_t paramLength[9] = {7, 6, 5, 6, 5, 4, 5, 4, 3};//func paramLength (state)
    if ((!self.params) || (self.params.count != paramLength[state])) {
        return ERROR;
    }
    
    
    return state;
}

- (int) getLength
{
    int length = 0;
    if (self.params) length += self.params.count;
    if (self.hp) length++;
    if (self.lp) length++;
    
    return length;
}

- (void) setHp:(PassFilter2 *)hp
{
    if (hp) {
        if (hp.biquadLength > BIQUAD_LENGTH_2) hp.biquadLength = BIQUAD_LENGTH_2;
        _hp = hp;
    
        
    } else {
        _hp = nil;
    }
    [self update];
}



- (void) setLp:(PassFilter2 *)lp
{
    if (lp) {
        if (lp.biquadLength > BIQUAD_LENGTH_2) lp.biquadLength = BIQUAD_LENGTH_2;
        _lp = lp;
    
    } else {
        _lp = nil;
    }
    [self update];
}

- (void) update {
    int paramLength = MAX_BIQUADS;
    
    if (self.hp) {
        self.hp.address0 = self.address0;
        self.hp.address1 = self.address1;
        paramLength -= self.hp.biquadLength;
    }
    if (self.lp){
        if (self.hp) {
            self.lp.address0 = self.address0 + self.hp.biquadLength;
            if (self.address1) {
                self.lp.address1 = self.address1 + self.hp.biquadLength;
            } else {
                self.lp.address1 = 0;
            }
        } else {
            self.lp.address0 = self.address0;
            self.lp.address1 = self.address1;
        }
        paramLength -= self.lp.biquadLength;
    }
    
    if (paramLength > 0) {
        ParamFilterContainer * temp = nil;
        
        //store enabled biquads to temp
        if (self.params) {
            temp = [[ParamFilterContainer alloc] init];
            
            
            for (int i = 0; i < self.params.count; i++) {
                ParamFilter * paramFilter = [self.params paramAtIndex:i];
                if ([paramFilter isActive]) [temp addParam:paramFilter];
            }
        }
        
        //fill new params
        self.params = [[ParamFilterContainer alloc] init];
         
        for (uint8_t i = 0; i < paramLength; i++) {
            int addrOffset = MAX_BIQUADS - paramLength + i;
            ParamFilter * param;
            
            if (i < temp.count) {
                param = [temp paramAtIndex:i];
                param.address0 = self.address0 + addrOffset;
                param.address1 = (self.address1) ? (self.address1 + addrOffset) : 0;
                
            } else {
                param = [ParamFilter initWithAddress0:self.address0 + addrOffset
                                             Address1:(self.address1) ? (self.address1 + addrOffset) : 0
                                                 Freq:100 Qfac:1.41 dbVolume:0.0
                                              Enabled:(i == 0) ? YES : NO];
            }
            [param setBorderMaxFreq:20000 minFreq:20];
                
            [self.params addParam:param];
        }
    } else {
        self.params = nil;
    }
}

//get AMPL FREQ response
- (double) getAFR:(double)freqX
{
    double resultAFR = 1.0;
    
    if (self.hp) resultAFR *= [self.hp getAFR:freqX];
    if (self.lp) resultAFR *= [self.lp getAFR:freqX];
    if (self.params) resultAFR *= [self.params getAFR:freqX];
    
    return resultAFR;
}

//info string
-(NSString *)getInfo
{
    NSString * infoStr;
    
    if (self.hp) {
        infoStr = [NSString stringWithFormat:@"HP=%d ", self.hp.biquadLength];
    } else {
        infoStr = @"HP=0 ";
    }
    
    if (self.lp) {
        infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"LP=%d ", self.lp.biquadLength]];
    } else {
        infoStr = [infoStr stringByAppendingString:@"LP=0 "];
    }
    
    if (self.params) {
        infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"Params=%d ", self.params.count]];
    } else {
        infoStr = [infoStr stringByAppendingString:@"Params=0 "];
    }
    
    return infoStr;
}


//send to dsp
- (void)sendWithResponse:(BOOL)response
{
    if (self.hp) [self.hp sendWithResponse:YES];
    if (self.lp) [self.lp sendWithResponse:YES];
    if (self.params) [self.params sendWithResponse:YES];
    
}


- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    if (self.hp) [data appendData:[self.hp getBinary]];
    if (self.lp) [data appendData:[self.lp getBinary]];
    if (self.params) [data appendData:[self.params getBinary]];
    
    return data;
}

- (BOOL)importData:(NSData *)data
{
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    if ((self.hp) && ([self.hp importData:data] == NO)) {
        return NO;
    }
    if ((self.lp) && ([self.lp importData:data] == NO)) {
        return NO;
    }
    if ((self.params) && ([self.params importData:data] == NO)) {
        return NO;
    }
    
    return YES;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];

    if (self.hp) [xmlData addXmlData:[_hp toXmlData]];
    if (self.lp) [xmlData addXmlData:[_lp toXmlData]];
    if (self.params) [xmlData addXmlData:[_params toXmlData]];
    
    XmlData * xoverXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address0] stringValue], @"Address0",
                           [[NSNumber numberWithInt:self.address1] stringValue], @"Address1", nil];
    
    
    [xoverXmlData addElementWithName:@"XOver" withXmlValue:xmlData withAttrib:dict];
    
    return xoverXmlData;
    
}

-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict {
    count = 0;
    [xmlParser pushDelegate:self];
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void)didFindXmlElement:(NSString *)elementName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict parser:(XmlParserWrapper *)xmlParser { 
    //get Address of Biquad
    NSString * addrStr = [attributeDict objectForKey:@"Address"];
    if (!addrStr) return;
    int addr = [addrStr intValue];
    
    if ((self.hp) && (self.hp.address == addr)){
        [self.hp importFromXml:xmlParser withAttrib:attributeDict];
        count += self.hp.biquadLength;
    }
    if ((self.lp) && (self.lp.address == addr)){
        [self.lp importFromXml:xmlParser withAttrib:attributeDict];
        count += self.lp.biquadLength;
    }
    if ((self.params) && (self.params.address == addr)){
        [self.params importFromXml:xmlParser withAttrib:attributeDict];
        count += self.params.count;
    }

}

- (void)didFoundXmlCharacters:(NSString *)characters forElement:(NSString *)elementName parser:(XmlParserWrapper *)xmlParser { 
    
}

- (void)didEndXmlElement:(NSString *)elementName parser:(XmlParserWrapper *)xmlParser {
    if ([elementName isEqualToString:@"XOver"]){

        if (count == 7){
            xmlParser.error = [NSString stringWithFormat:
                               @"XOver=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:[self address]] stringValue] ];
            
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}

@end
