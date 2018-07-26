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
        _hp = [decoder decodeObjectForKey:@"keyHP"];
        _lp = [decoder decodeObjectForKey:@"keyLP"];
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
    
    [currentInstance updateParam];
    
    return currentInstance;
}

//mono
+ (XOver *)initWithAddress:(int)address
                    Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp
{
    return [self initWithAddress0:address Address1:0 Params:params Hp:hp Lp:lp];
}

//stereo default
+ (XOver *)initDefaultWithAddress0:(int)address0 Address1:(int)address1
{
    //HP
    PassFilter2 * hp = [PassFilter2 initWithAddress0:address0 Address1:address1
                                               Order:FILTER_ORDER_0 Type:BIQUAD_HIGHPASS Freq:60];
    //LP
    PassFilter2 * lp = [PassFilter2 initWithAddress0:address0 + 2 Address1:(address1) ? (address1 + 2) : 0
                                               Order:FILTER_ORDER_0 Type:BIQUAD_LOWPASS Freq:10000];
    
    //Parametric biquads
    ParamFilterContainer * params = [[ParamFilterContainer alloc] init];
    
    for (uint i = 0; i < 7; i++) {
        ParamFilter * param = [ParamFilter initWithAddress0:address0 + i
                                                   Address1:(address1) ? (address1 + i) : 0
                                                       Freq:100 * (i + 1) Qfac:1.41 dbVolume:0.0
                                                    Enabled:YES];
        [param setBorderMaxFreq:20000 minFreq:20];
        
        [params addParam:param];
    }
    
    return [self initWithAddress0:address0 Address1:address1 Params:params Hp:hp Lp:lp];
}

- (uint8_t)address {
    return self.address0;
    
}

//setters/getters
- (int) getLength
{
    int length = 0;
    if (self.params) length += self.params.count;
    if (self.hp) length++;
    if (self.lp) length++;
    
    return length;
}

- (void) setOrder:(PassFilterOrder_t)order forPassFilter:(PassFilter2 *)passFilter
{
    if ((order < FILTER_ORDER_0) || (order > FILTER_ORDER_8)) return;
    if ((!passFilter) || (passFilter.order == order)) return;
    
    if (passFilter.order == FILTER_ORDER_0) {
        if (order == FILTER_ORDER_2) {
            
            ParamFilter * param = [self.params findParamWithAddr:passFilter.address0];
            [self.params removeWithPossibleReplace:param];
            
        } else if (order == FILTER_ORDER_4) {
            
            ParamFilter * param = [self.params findParamWithAddr:passFilter.address0];
            [self.params removeWithPossibleReplace:param];
            param = [self.params findParamWithAddr:passFilter.address0 + 1];
            [self.params removeWithPossibleReplace:param];
        }
    } else if (passFilter.order == FILTER_ORDER_2) {
        
        if (order == FILTER_ORDER_0) {
            
            int freq = [self getFreqForNextEnabledParametric];
            
            ParamFilter * param = [ParamFilter initWithAddress0:passFilter.address0
                                                       Address1:passFilter.address1
                                                           Freq:freq Qfac:1.41 dbVolume:0.0
                                                        Enabled:YES];
            [self.params addParam:param];
            [param sendWithResponse:YES];
            
        } else if (order == FILTER_ORDER_4) {

            ParamFilter * param = [self.params findParamWithAddr:passFilter.address0 + 1];
            [self.params removeWithPossibleReplace:param];
        }
        
    } else if (passFilter.order == FILTER_ORDER_4) {
        
        if (order == FILTER_ORDER_0) {
            
            int freq = [self getFreqForNextEnabledParametric];
            
            ParamFilter * param = [ParamFilter initWithAddress0:passFilter.address0
                                                       Address1:passFilter.address1
                                                           Freq:freq Qfac:1.41 dbVolume:0.0
                                                        Enabled:YES];
            [self.params addParam:param];
            [param sendWithResponse:YES];
            
            freq = [self getFreqForNextEnabledParametric];
            
            param = [ParamFilter initWithAddress0:passFilter.address0 + 1
                                         Address1:(passFilter.address1) ? (passFilter.address1 + 1) : 0
                                             Freq:freq Qfac:1.41 dbVolume:0.0
                                          Enabled:YES];
            [self.params addParam:param];
            [param sendWithResponse:YES];
            
        } else if (order == FILTER_ORDER_2) {
            
            int freq = [self getFreqForNextEnabledParametric];
            
            ParamFilter * param = [ParamFilter initWithAddress0:passFilter.address0 + 1
                                                       Address1:(passFilter.address1) ? (passFilter.address1 + 1) : 0
                                                           Freq:freq Qfac:1.41 dbVolume:0.0
                                                        Enabled:YES];
            [self.params addParam:param];
            [param sendWithResponse:YES];
        }
    }
    
    passFilter.order = order;
    [passFilter sendWithResponse:YES];
}

//transfer param from pass biquad or remove
- (void) updateParam {
    
    if ((!self.params) || (self.params.count == 0)) return;
    
    if ((self.hp) && (self.hp.order != FILTER_ORDER_0)) {
        if (self.hp.order >= FILTER_ORDER_2) {
            ParamFilter * param = [self.params findParamWithAddr:self.hp.address0];
            [self.params removeWithPossibleReplace:param];
        }
        if (self.hp.order == FILTER_ORDER_4) {
            ParamFilter * param = [self.params findParamWithAddr:self.hp.address0 + 1];
            [self.params removeWithPossibleReplace:param];
        }
    }
    
    if ((self.lp) && (self.lp.order != FILTER_ORDER_0)) {
        if (self.lp.order >= FILTER_ORDER_2) {
            ParamFilter * param = [self.params findParamWithAddr:self.lp.address0];
            [self.params removeWithPossibleReplace:param];
        }
        if (self.lp.order == FILTER_ORDER_4) {
            ParamFilter * param = [self.params findParamWithAddr:self.lp.address0 + 1];
            [self.params removeWithPossibleReplace:param];
        }
    }
    
}

- (int) getFreqForNextEnabledParametric {
    int freq = -1;
    
    NSMutableArray * freqs = [[NSMutableArray alloc] init];
    
    //get freqs from all params, hp, lp
    if (self.params) {
        for (int i = 0; i < self.params.count; i++) {
            ParamFilter * param = [self.params paramAtIndex:i];
            if ([param isEnabled]) {
                [freqs addObject:[NSNumber numberWithInt:param.freq]];
                
            }
        }
    }
    if (self.hp) [freqs addObject:[NSNumber numberWithInt:self.hp.freq]];
    if (self.lp) [freqs addObject:[NSNumber numberWithInt:self.lp.freq]];
    
    if (freqs.count < 2) return freq;
    
    //sort freqs
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [freqs sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    //get max delta freq
    int maxIndex = 0;
    int maxDFreq = 0;
    for (int i = 0; i < freqs.count - 1; i++){
        int f0 = [[freqs objectAtIndex:i] intValue];
        int f1 = [[freqs objectAtIndex:i + 1] intValue];
        
        if (f1 - f0 > maxDFreq){
            maxDFreq = f1 - f0;
            maxIndex = i;
        }
    }
    
    int f0 = [[freqs objectAtIndex:maxIndex] intValue];
    int f1 = [[freqs objectAtIndex:maxIndex + 1] intValue];
    
    //freq calculate
    double dfreq = (log10(f0) + log10(f1)) / 2;
    freq = pow(10, dfreq);
    
    return freq;
}

/*- (void) update {
    int paramLength = MAX_BIQUADS;
    
    if (self.hp) {
        self.hp.address0 = self.address0;
        self.hp.address1 = self.address1;
        paramLength -= self.hp.order;
    }
    if (self.lp){
        self.lp.address0 = _address0 + 2;
        self.lp.address1 = (_address1) ? (_address1 + 2) : 0;
        paramLength -= self.lp.order;
    }
    
    
    if (paramLength > 0) {
        ParamFilterContainer * temp = nil;
        
        if (self.params) {
            //get copy and sort
            temp = [self.params copy];
            [temp sortActive];
        }
        
        
        //fill new params
        self.params = [[ParamFilterContainer alloc] init];
         
        for (uint8_t i = 0; i < paramLength; i++) {
            int addrOffset = MAX_BIQUADS - paramLength + i;
            ParamFilter * param;
            
            if ((temp) && (i < temp.count)) {
                param = [temp paramAtIndex:i];
                param.address0 = self.address0 + addrOffset;
                param.address1 = (self.address1) ? (self.address1 + addrOffset) : 0;
                
            } else {
                param = [ParamFilter initWithAddress0:self.address0 + addrOffset
                                             Address1:(self.address1) ? (self.address1 + addrOffset) : 0
                                                 Freq:100 * (i + 1) Qfac:1.41 dbVolume:0.0
                                              Enabled:YES];
            }
            [param setBorderMaxFreq:20000 minFreq:20];
                
            [self.params addParam:param];
        }
    } else {
        self.params = nil;
    }
}*/

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
        infoStr = [NSString stringWithFormat:@"HP=%d ", self.hp.order];
    } else {
        infoStr = @"HP=0 ";
    }
    
    if (self.lp) {
        infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"LP=%d ", self.lp.order]];
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
    int addr[2] = {self.address0, self.address1};
    
    //create default hp and import
    PassFilter2 * hp = [PassFilter2 initWithAddress0:addr[0] Address1:addr[1]
                                               Order:FILTER_ORDER_0 Type:BIQUAD_HIGHPASS Freq:100];
    
    if (([hp importData:data]) && (hp.type == BIQUAD_HIGHPASS)) {
        
        self.hp = hp;
        
        addr[0] += hp.order;
        if (addr[1]) addr[1] += hp.order;
    } else {
        self.hp = nil;
    }
    
    //create default lp and import
    PassFilter2 * lp = [PassFilter2 initWithAddress0:addr[0] Address1:addr[1]
                                               Order:FILTER_ORDER_0 Type:BIQUAD_LOWPASS Freq:100];
    
    if (([lp importData:data]) && (hp.type == BIQUAD_LOWPASS)){
        
        self.lp = lp;
        
        addr[0] += lp.order;
        if (addr[1]) addr[1] += lp.order;
    } else {
        self.lp = nil;
    }
    
    //import params
    if (!self.params) {
        self.params = [[ParamFilterContainer alloc] init];
    } else {
        [self.params clear];
    }
    
    while (addr[0] < self.address0 + 7) {
        ParamFilter * param = [ParamFilter initWithAddress0:addr[0] Address1:addr[1] Freq:100 Qfac:1.41 dbVolume:0.0 Enabled:NO];
        
        if (![param importData:data]) return NO;
        [self.params addParam:param];
       
        addr[0]++;
        if (addr[1]) addr[1]++;
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
        count += self.hp.order;
    }
    if ((self.lp) && (self.lp.address == addr)){
        [self.lp importFromXml:xmlParser withAttrib:attributeDict];
        count += self.lp.order;
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
