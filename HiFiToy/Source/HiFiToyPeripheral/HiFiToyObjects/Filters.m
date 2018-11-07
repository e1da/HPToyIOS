//
//  Filters.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "Filters.h"
#import "BiquadLL.h"
#import "PassFilter.h"
#import "FloatUtility.h"


@interface Filters () {
@private
    BiquadLL * biquads[7];
    int count;
    
}

@end

@implementation Filters

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.address0 forKey:@"keyAddress0"];
    [encoder encodeInt:self.address1 forKey:@"keyAddress1"];
    
    for (int i = 0; i < 7; i++) {
        NSString * keyStr = [NSString stringWithFormat:@"keyBiquad[%d]", i ];
        [encoder encodeObject:biquads[i] forKey:keyStr];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.address0 = [decoder decodeIntForKey:@"keyAddress0"];
        self.address1 = [decoder decodeIntForKey:@"keyAddress1"];
        
        for (int i = 0; i < 7; i++) {
            NSString * keyStr = [NSString stringWithFormat:@"keyBiquad[%d]", i ];
            BiquadLL * b = [decoder decodeObjectForKey:keyStr];
            
            [self setBiquad:b forIndex:i];
        }
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(Filters *)copyWithZone:(NSZone *)zone
{
    Filters * copyFilters = [[[self class] allocWithZone:zone] init];
    
    copyFilters.address0 = self.address0;
    copyFilters.address1 = self.address1;
    copyFilters.activeBiquadIndex = self.activeBiquadIndex;
    
    for (int i = 0; i < 7; i++) {
        [copyFilters setBiquad:[biquads[i] copy] forIndex:i];
    }

    return copyFilters;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ((object) && ([object class] == [self class])) {
        Filters * temp = object;
        
        if ((self.address0 != temp.address0) ||
            (self.address1 != temp.address1)) {
            return NO;
        }
        
        for (int i = 0; i < 7; i++) {
            BiquadLL * tempBiquad = [temp getBiquadAtIndex:i];
            
            if ([tempBiquad isEqual:biquads[i]] == NO) {
                return NO;
            }
        }
        
        return YES;
    }
    return NO;
}

/*============================= Init and create methods ===================================*/
-(id) init {
    self = [super init];
    if (self) {
        for (int i = 0; i < 7; i++) {
            biquads[i] = [[BiquadLL alloc] init];
        }
        self.activeBiquadIndex = 0;
    }
    return self;
}


+ (Filters *) initDefaultWithAddr0:(int)addr0 withAddr1:(int)addr1 {
    Filters * instance = [[Filters alloc] init];
    
    instance.address0 = addr0;
    instance.address1 = addr1;
    
    for (int i = 0; i < 7; i++) {
        BiquadLL * biquad = [BiquadLL initWithAddress0:addr0 + i
                                              Address1:(addr1) ? (addr1 + i) : 0];
        
        [biquad.biquadParam setBorderMaxFreq:20000 minFreq:20];
        
        biquad.type     = BIQUAD_PARAMETRIC;
        biquad.biquadParam.freq     = 100 * (i + 1);
        biquad.biquadParam.qFac     = 1.41f;
        biquad.biquadParam.dbVolume = 0.0f;
        
        [instance setBiquad:biquad forIndex:i];
    }
    
    return instance;
}

- (uint8_t)address {
    return self.address0;
}

- (void) setActiveNullHP:(BOOL)activeNullHP {
    _activeNullHP = activeNullHP;
    if (_activeNullHP) _activeNullLP = NO;
}

- (void) setActiveNullLP:(BOOL)activeNullLP {
    _activeNullLP = activeNullLP;
    if (_activeNullLP) _activeNullHP = NO;
}

/*============================= Biquad get/set methods ===================================*/
- (uint8_t) getBiquadLength {
    return 7;
}

- (BiquadLL *) getBiquadAtIndex:(uint8_t)index {
    if (index < 7) {
        return biquads[index];
    }
    return nil;
}

- (int) getBiquadIndex:(BiquadLL *)biquad {
    for (int i = 0; i < 7; i++) {
        if (biquads[i] == biquad) {
            return i;
        }
    }
    return -1;
}

- (BiquadLL *)  getActiveBiquad {
    return [self getBiquadAtIndex:_activeBiquadIndex];
}

- (void) setBiquad:(BiquadLL *)biquad forIndex:(uint8_t)index {
    if (index > 6) return;
    
    biquads[index] = biquad;
}

- (void) setActiveBiquadIndex:(uint8_t)activeBiquadIndex {
    if (_activeBiquadIndex > 6) _activeBiquadIndex = 6;
    _activeBiquadIndex = activeBiquadIndex;
}

- (BiquadType_t *) getBiquadTypes {
    BiquadType_t * types = malloc(7 * sizeof(BiquadType_t));
    for (int i = 0; i < 7; i++) {
        types[i] = biquads[i].type;
    }
    return types;
}

- (void) incActiveBiquadIndex {
    if (++_activeBiquadIndex > 6) _activeBiquadIndex = 0;
    _activeNullHP = NO;
    _activeNullLP = NO;
}

- (void) decActiveBiquadIndex {
    if (_activeBiquadIndex == 0) {
        _activeBiquadIndex = 6;
    } else {
        _activeBiquadIndex--;
    }
    _activeNullHP = NO;
    _activeNullLP = NO;
}

- (void) nextActiveBiquadIndex {
    BiquadType_t type = [[self getBiquadAtIndex:_activeBiquadIndex] type];
    BiquadType_t nextType;
    BiquadLL * b;
    int counter = 0;
    
    do {
        if (++counter > 7) break;
        
        _activeBiquadIndex++;
        if (_activeBiquadIndex > 6) _activeBiquadIndex = 0;
        
        b = [self getBiquadAtIndex:_activeBiquadIndex];
        nextType = b.type;
        
    } while (((type == BIQUAD_LOWPASS) && (nextType == BIQUAD_LOWPASS)) ||
             ((type == BIQUAD_HIGHPASS) && (nextType == BIQUAD_HIGHPASS)) ||
             (!b.enabled));
    
    if (counter > 7) {
        //error
    }
}

- (void) prevActiveBiquadIndex {
    BiquadType_t type = [[self getBiquadAtIndex:_activeBiquadIndex] type];
    BiquadType_t nextType;
    BiquadLL * b;
    int counter = 0;
    
    do {
        if (++counter > 7) break;
        
        _activeBiquadIndex--;
        if (_activeBiquadIndex > 6) _activeBiquadIndex = 6;
        
        b = [self getBiquadAtIndex:_activeBiquadIndex];
        nextType = b.type;
        
    } while (((type == BIQUAD_LOWPASS) && (nextType == BIQUAD_LOWPASS)) ||
             ((type == BIQUAD_HIGHPASS) && (nextType == BIQUAD_HIGHPASS)) ||
             (!b.enabled));
    
    if (counter > 7) {
        //error
    }
}

- (BOOL) swapBiquads:(uint8_t)index0 withBiquad:(uint8_t)index1 {
    if ((index0 >= 7) || (index1 >= 7)) return NO;
    
    BiquadLL * b0 = [self getBiquadAtIndex:index0];
    BiquadLL * b1 = [self getBiquadAtIndex:index1];
    BiquadLL * tempBiquad = [b0 copy];
    tempBiquad.address0 = b1.address0;
    tempBiquad.address1 = b1.address1;
    b1.address0 = b0.address0;
    b1.address1 = b0.address1;
    
    [self setBiquad:b1 forIndex:index0];
    [self setBiquad:tempBiquad forIndex:index1];
    return YES;
}

- (NSArray<BiquadLL *> *) getBiquadsWithType:(BiquadType_t)type {
    NSMutableArray * biquads = nil;
    
    for (int i = 0 ; i < 7; i++) {
        BiquadLL * b = [self getBiquadAtIndex:i];
        
        if (b.type == type) {
            
            if (biquads) {
                [biquads addObject:b];
            } else {
                biquads = [[NSMutableArray alloc] initWithObjects:b, nil];
            }
        }
    }
    return biquads;
}

- (BiquadLL *) getFreeBiquad {
    NSArray<BiquadLL *> * offBiquads = [self getBiquadsWithType:BIQUAD_OFF];
    if ((offBiquads) && (offBiquads.count > 0)) {
        return [offBiquads objectAtIndex:0];
    }
    
    NSArray<BiquadLL *> * paramBiquads = [self getBiquadsWithType:BIQUAD_PARAMETRIC];
    if ((paramBiquads) && (paramBiquads.count > 0)) {
        
        //try find parametric with db == 0
        for (int i = 0; i < paramBiquads.count; i++) {
            BiquadLL * p = [paramBiquads objectAtIndex:i];
            
            if (isFloatNull(p.biquadParam.dbVolume)) {
                return p;
            }
        }
        
        //find parametric with min abs db
        BiquadLL * p = [paramBiquads objectAtIndex:0];
        for (int i = 1; i < paramBiquads.count; i++) {
            if ( (fabsf(p.biquadParam.dbVolume)) > (fabsf([[paramBiquads objectAtIndex:i] biquadParam].dbVolume)) ) {
                p = [paramBiquads objectAtIndex:i];
            }
        }
        return p;
    }
    
    NSArray<BiquadLL *> * allpassBiquads = [self getBiquadsWithType:BIQUAD_ALLPASS];
    if ((allpassBiquads) && (allpassBiquads.count > 0)) {
        return [offBiquads objectAtIndex:0];
    }
    
    return nil;
}

- (PassFilter *) getLowpass {
    NSArray<BiquadLL *> * lpBiquads = [self getBiquadsWithType:BIQUAD_LOWPASS];
    if (!lpBiquads) return nil;
    
    return [PassFilter initWithBiquads:lpBiquads withType:BIQUAD_LOWPASS];
}

- (PassFilter *) getHighpass {
    NSArray<BiquadLL *> * hpBiquads = [self getBiquadsWithType:BIQUAD_HIGHPASS];
    if (!hpBiquads) return nil;
    
    return [PassFilter initWithBiquads:hpBiquads withType:BIQUAD_HIGHPASS];
}

- (BOOL) isLowpassFull {
    NSArray<BiquadLL *> * lpBiquads = [self getBiquadsWithType:BIQUAD_LOWPASS];

    return (lpBiquads) && (lpBiquads.count >= 2);
}

- (BOOL) isHighpassFull {
    NSArray<BiquadLL *> * hpBiquads = [self getBiquadsWithType:BIQUAD_HIGHPASS];
    
    return (hpBiquads) && (hpBiquads.count >= 2);
}

- (void) upOrderFor:(PassFilterType_t) type {
    int freq;
    
    //check type and get freq
    if (type == BIQUAD_LOWPASS) {
        if ([self isLowpassFull]) return;
        PassFilter * lp = [self getLowpass];
        freq = (lp) ? lp.Freq : 20000;
    } else if (type == BIQUAD_HIGHPASS) {
        if ([self isHighpassFull]) return;
        PassFilter * hp = [self getHighpass];
        freq = (hp) ? hp.Freq : 20;
    } else {
        return;
    }

    NSArray<BiquadLL *> * biquads = [self getBiquadsWithType:type];
    
    if ((!biquads) || (biquads.count < 2)) {//need 1 biquad
        BiquadLL * b = [self getFreeBiquad];
        if (b) {
            b.enabled = YES;
            b.type = type;
            b.biquadParam.freq = freq;
        }
        
    } else if (biquads.count == 2) { //need 2 biquads
        BiquadLL * b0 = [self getFreeBiquad];
        BiquadLL * b1 = [self getFreeBiquad];
        
        if ((b0) && (b1)) {
            b0.enabled = YES;
            b0.type = type;
            b0.biquadParam.freq = freq;
            b1.enabled = YES;
            b1.type = type;
            b1.biquadParam.freq = freq;
        }
    } else {
        return;
    }
    
    //get biquads
    biquads = [self getBiquadsWithType:type];
    //set active biquad index
    int index = [self getBiquadIndex:[biquads objectAtIndex:0]];
    if (index != -1) {
        _activeBiquadIndex = index;
        if ((type == BIQUAD_LOWPASS) && (self.activeNullLP)) self.activeNullLP = NO;
        if ((type == BIQUAD_HIGHPASS) && (self.activeNullHP)) self.activeNullHP = NO;
    }
    
    //update lp biquads with order
    PassFilter * p = [PassFilter initWithBiquads:biquads withType:type];
    [p sendWithResponse:YES];
    
}

- (void) downOrderFor:(PassFilterType_t)type {
    if ((type != BIQUAD_LOWPASS) && (type != BIQUAD_HIGHPASS)) return;
    
    NSArray<BiquadLL *> * biquads = [self getBiquadsWithType:type];
    if ((!biquads) || (!biquads.count)) return;
    
    int s = (int)biquads.count;
    
    if (biquads.count > 4) {
        s = 4;
    } else if (biquads.count > 2) {
        s = 2;
    } else if (biquads.count > 1) {
        s = 1;
    } else if (biquads.count == 1) {
        s = 0;
    }
    
    //free excess biquads from LP and set to Parametric
    for (int i = s; i < biquads.count; i++) {
        BiquadLL * b = [biquads objectAtIndex:i];
        
        b.enabled = [self isPEQEnabled];
        b.type = BIQUAD_PARAMETRIC;
        
        int freq = [self getBetterNewFreq];
        b.biquadParam.freq = (freq != -1) ? freq : 100;
        
        b.biquadParam.qFac = 1.41f;
        b.biquadParam.dbVolume = 0.0f;
        
        [b sendWithResponse:YES];
    }
    
    //get lp biquads
    biquads = [self getBiquadsWithType:type];
    if (biquads.count == 0) {
        if (type == BIQUAD_LOWPASS) self.activeNullLP = YES;
        if (type == BIQUAD_HIGHPASS) self.activeNullHP = YES;
    }
    
    //update lp biquads with order
    PassFilter * p = [PassFilter initWithBiquads:biquads withType:type];
    [p sendWithResponse:YES];
}

- (BOOL) isPEQEnabled {
    BOOL result = YES;
    
    NSMutableArray<BiquadLL *> * biquads = [[NSMutableArray alloc] init];
    [biquads addObjectsFromArray:[self getBiquadsWithType:BIQUAD_PARAMETRIC]];
    [biquads addObjectsFromArray:[self getBiquadsWithType:BIQUAD_ALLPASS]];
    
    if ((!biquads) || (!biquads.count) ) return NO;
    
    for (int i = 0; i < biquads.count; i++) {
        BiquadLL * b = [biquads objectAtIndex:i];
        if (!b.enabled) {
            result = NO;
            break;
        }
    }
    
    if (!result) {
        for (int i = 0; i < biquads.count; i++) {
            BiquadLL * b = [biquads objectAtIndex:i];
            if (b.enabled) {
                b.enabled = NO;
                [b sendWithResponse:YES];
            }
        }
    }
    return result;
}

//set enablend and send to dsp
- (void) setPEQEnabled:(BOOL)enabled {
    //NSArray<BiquadLL *> * biquads = [self getBiquadsWithType:BIQUAD_PARAMETRIC];
    NSMutableArray<BiquadLL *> * biquads = [[NSMutableArray alloc] init];
    [biquads addObjectsFromArray:[self getBiquadsWithType:BIQUAD_PARAMETRIC]];
    [biquads addObjectsFromArray:[self getBiquadsWithType:BIQUAD_ALLPASS]];
 
    for (int i = 0; i < biquads.count; i++) {
        BiquadLL * b = [biquads objectAtIndex:i];
        if (b.enabled != enabled) {
            b.enabled = enabled;
            [b sendWithResponse:YES];
        }
    }
    
    BiquadLL * b = [self getBiquadAtIndex:self.activeBiquadIndex];
    if (!b.enabled) {
        [self nextActiveBiquadIndex];
    }
}

- (int) getBetterNewFreq {
    int freq = -1;
    
    NSMutableArray * freqs = [[NSMutableArray alloc] init];
    
    //get freqs from all params, hp, lp
    for (int i = 0; i < 7; i++) {
        if (biquads[i].enabled) {
            [freqs addObject:[NSNumber numberWithInt:biquads[i].biquadParam.freq]];
        }
    }
    if (![self getLowpass]) [freqs addObject:[NSNumber numberWithInt:20000]];
    if (![self getHighpass]) [freqs addObject:[NSNumber numberWithInt:20]];

    if (freqs.count < 2) return freq;
    
    //sort freqs
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [freqs sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    //get max delta freq
    int maxIndex = 0;
    float maxDLogFreq = 0;
    for (int i = 0; i < freqs.count - 1; i++){
        int f0 = [[freqs objectAtIndex:i] intValue];
        int f1 = [[freqs objectAtIndex:i + 1] intValue];
        
        if (log10(f1) - log10(f0) > maxDLogFreq){
            maxDLogFreq = log10(f1) - log10(f0);
            maxIndex = i;
        }
    }
    
    //freq calculate
    float log_f0 = log10([[freqs objectAtIndex:maxIndex] intValue]);
    double log_freq = log_f0 + maxDLogFreq / 2;
    freq = pow(10, log_freq);
    
    return freq;
}


//get AMPL FREQ response
- (double) getAFR:(double)freqX {
    double resultAFR = 1.0;
    
    for (int i = 0; i < 7; i++) {
        resultAFR *= [biquads[i] getAFR:freqX];
    }
    return resultAFR;
}

/*============================= HiFiToyObject protocol methods ===================================*/
- (NSString *)getInfo {
    return @"Filters is 7 biquads";
}

- (NSData *)getBinary {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    for (int i = 0; i < 7; i++) {
        [data appendData:[biquads[i] getBinary]];
    }
    
    return data;
}

- (BOOL)importData:(NSData *)data {
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    for (int i = 0; i < 7; i++) {
        biquads[i].type = HiFiToy->biquadTypes[i];
    }
    
    for (int i = 0; i < 7; i++) {
        if (![biquads[i] importData:data]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)sendWithResponse:(BOOL)response {
    for (int i = 0; i < 7; i++) {
        [biquads[i] sendWithResponse:YES];
    }
}

/*---------------------------- XML export/import ----------------------------------*/
- (XmlData *)toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    
    for (int i = 0; i < 7; i++) {
        [xmlData addXmlData:[biquads[i] toXmlData]];
    }
    
    XmlData * filtersXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address0] stringValue], @"Address",
                           [[NSNumber numberWithInt:self.address1] stringValue], @"Address1", nil];
    
    
    [filtersXmlData addElementWithName:@"Filters" withXmlValue:xmlData withAttrib:dict];
    
    return filtersXmlData;
}

- (void)importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *,NSString *> *)attributeDict {
    count = 0;
    [xmlParser pushDelegate:self];
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void)didFindXmlElement:(NSString *)elementName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict parser:(XmlParserWrapper *)xmlParser {
    //get Address of Biquad
    NSString * addrStr = [attributeDict objectForKey:@"Address"];
    if (!addrStr) return;
    int addr = [addrStr intValue];
    
    for (int i = 0; i < 7; i++) {
        if ([biquads[i] address] == addr) {
            [biquads[i] importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
    }
    
}

- (void)didFoundXmlCharacters:(NSString *)characters forElement:(NSString *)elementName parser:(XmlParserWrapper *)xmlParser {
    
}

- (void)didEndXmlElement:(NSString *)elementName parser:(XmlParserWrapper *)xmlParser {
    if ([elementName isEqualToString:@"Filters"]){
        
        if (count != 7){
            xmlParser.error = [NSString stringWithFormat:
                               @"Filters=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:[self address]] stringValue] ];
            
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
