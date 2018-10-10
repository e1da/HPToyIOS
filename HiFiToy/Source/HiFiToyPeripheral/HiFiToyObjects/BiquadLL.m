//
//  BiquadLL.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BiquadLL.h"
#import "HiFiToyControl.h"
#import "FloatUtility.h"

@interface BiquadLL(){
    int count;
}
@end

bool isCoefEqual(float c0, float c1) {
    return isFloatEqualWithAccuracy(c0, c1, 16);
}

bool isBiquadCoefEqual(BiquadCoef_t arg0, BiquadCoef_t arg1) {
    if ((isFloatEqualWithAccuracy(arg0.a1, arg1.a1, 16)) &&
         (isFloatEqualWithAccuracy(arg0.a2, arg1.a2, 16)) &&
          (isFloatEqualWithAccuracy(arg0.b0, arg1.b0, 16)) &&
           (isFloatEqualWithAccuracy(arg0.b1, arg1.b1, 16)) &&
            (isFloatEqualWithAccuracy(arg0.b2, arg1.b2, 16)) ) {
                return true;
            }
    return false;
}


@implementation BiquadLL

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.address0 forKey:@"keyAddress0"];
    [encoder encodeInt:self.address1 forKey:@"keyAddress1"];
    
    [encoder encodeBytes:(uint8_t *)&_coef length:sizeof(BiquadCoef_t) forKey:@"keyCoef"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.address0 = [decoder decodeIntForKey:@"keyAddress0"];
        self.address1 = [decoder decodeIntForKey:@"keyAddress1"];
        
        NSUInteger size = sizeof(BiquadCoef_t);
        const uint8_t * p = [decoder decodeBytesForKey:@"keyCoef" returnedLength:&size];
        memcpy(&_coef, p, size);
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(BiquadLL *)copyWithZone:(NSZone *)zone {
    BiquadLL * copyBiquad = [[[self class] allocWithZone:zone] init];
    
    copyBiquad.address0 = self.address0;
    copyBiquad.address1 = self.address1;
    copyBiquad.coef = self.coef;
    
    copyBiquad.maxFreq = self.maxFreq;
    copyBiquad.minFreq = self.minFreq;
    copyBiquad.maxQ = self.maxQ;
    copyBiquad.minQ = self.minQ;
    copyBiquad.maxDbVol = self.maxDbVol;
    copyBiquad.minDbVol = self.minDbVol;
    
    return copyBiquad;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    
    if ([object class] == [self class]) {
        BiquadLL * temp = object;
        
        if ((self.address0 == temp.address0) &&
            (self.address1 == temp.address1) &&
            (isBiquadCoefEqual(self.coef, temp.coef)) &&
            
            (self.maxFreq == temp.maxFreq) &&
            (self.minFreq == temp.minFreq) &&
            (isFloatDiffLessThan(self.maxQ, temp.maxQ, 0.01f)) &&
            (isFloatDiffLessThan(self.minQ, temp.minQ, 0.01f)) &&
            (isFloatDiffLessThan(self.maxDbVol, temp.maxDbVol, 0.01f)) &&
            (isFloatDiffLessThan(self.minDbVol, temp.minDbVol, 0.01f)) ) {
            return YES;
        }
    }
    
    
    return NO;
}


/*---------------------- create method -----------------------------*/
+ (BiquadLL *)initWithAddress:(int)address {
    return [BiquadLL initWithAddress0:address Address1:0];
}

+ (BiquadLL *)initWithAddress0:(int)address0 Address1:(int)address1 {
    BiquadLL *currentInstance = [[BiquadLL alloc] init];
    
    currentInstance.address0 = address0;
    currentInstance.address1 = address1;
    
    BiquadParam_t param;
    param.order = BIQUAD_ORDER_2;
    param.type = BIQUAD_DISABLED;
    
    [currentInstance setBiquadParam:param];
    
    return currentInstance;
}

- (uint8_t)address {
    return self.address0;
    
}

/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (double) get_LPF:(double)freqX
{
    BiquadParam_t param = [self getBiquadParam];
    return sqrt(1.0f/(  pow(1 - pow(freqX / param.freq, 2), 2) + pow(freqX / (param.freq * param.qFac), 2)    ));
}

- (double) get_HPF:(double)freqX
{
    BiquadParam_t param = [self getBiquadParam];
    return sqrt(pow( pow(freqX / param.freq , 4) - pow(freqX / param.freq, 2) , 2) +
                pow(freqX / param.freq, 6) / pow(param.qFac, 2))
                / (pow(1 - pow(freqX / param.freq, 2), 2) + pow(freqX / (param.qFac * param.freq), 2));
}

- (double) get_PeakingEQ:(double)freqX
{
    BiquadParam_t param = [self getBiquadParam];
    
    double Ampl = pow(10, param.dbVolume / 40);
    double A1 = pow(1 - pow(freqX / param.freq, 2), 2) + pow(freqX / (param.qFac * param.freq), 2);
    double A2 = (1 - pow(freqX / param.freq, 2)) *
                (freqX * Ampl / (param.qFac * param.freq) - freqX / (Ampl * param.qFac * param.freq));
    
    double B = pow(1 - pow(freqX / param.freq, 2), 2) + pow(freqX / (Ampl * param.qFac * param.freq), 2);
    
    
    return  sqrt(pow(A1, 2) + pow(A2, 2)) / B;
}

- (double) getAFR:(double)freqX
{
    BiquadParam_t param = [self getBiquadParam];
    
    if (param.order == BIQUAD_ORDER_2) {
        switch (param.type) {
            case BIQUAD_LOWPASS:
                return [self get_LPF:freqX];
                break;
            case BIQUAD_HIGHPASS:
                return [self get_HPF:freqX];
                break;
            case BIQUAD_PARAMETRIC:
                return [self get_PeakingEQ:freqX];
                break;
            case BIQUAD_DISABLED:
                return 1.0f;
                break;
            default:
                return 1.0f;
                break;
        }
    } else {
        return 1.0f;
    }
}


//setters/getters
- (BiquadOrder_t) getOrder {
    if ( (isFloatNull(_coef.b2)) && (isFloatNull(_coef.a2)) && (!isFloatNull(_coef.b0)) && (!isFloatNull(_coef.b1)) && (!isFloatNull(_coef.a1)) ) {
        return BIQUAD_ORDER_1;
    }
    return BIQUAD_ORDER_2;
}

- (void) setOrder:(BiquadOrder_t)order {
    BiquadParam_t param = [self getBiquadParam];
    param.order = order;
    [self setBiquadParam:param];
}

- (BiquadType_t) getType {
    
    if ( (isCoefEqual(_coef.b0, 1.0f)) && (isFloatNull(_coef.b1)) && (isFloatNull(_coef.b2)) &&
        (isFloatNull(_coef.a1)) && (isFloatNull(_coef.a2)) ) {
        return BIQUAD_DISABLED;
        
    } else if ((isCoefEqual(_coef.b1, 2 * _coef.b0)) && (isCoefEqual(_coef.b0, _coef.b2)) ) {
        return BIQUAD_LOWPASS;
        
    } else if ((isCoefEqual(_coef.b1, -2 * _coef.b0)) && (isCoefEqual(_coef.b0, _coef.b2)) ) {
        return BIQUAD_HIGHPASS;
        
    } else if ((isCoefEqual(_coef.b1, -_coef.a1)) && (isCoefEqual(_coef.b0, -_coef.a2)) ) {
        return BIQUAD_ALLPASS;
        
    } else if (isCoefEqual(_coef.b1, -_coef.a1)) {
        return BIQUAD_PARAMETRIC;
        
    } else if ((isFloatNull(_coef.b1)) && (isCoefEqual(_coef.b0, -_coef.b2)) ) {
        return BIQUAD_BANDPASS;
    }
    
    return BIQUAD_USER;
}

- (void) setType:(BiquadType_t)type {
    BiquadParam_t param = [self getBiquadParam];
    param.type = type;
    [self setBiquadParam:param];
}

- (int) getFreq {
    BiquadParam_t param = [self getBiquadParam];
    return param.freq;
}

- (void) setFreq:(int)freq {
    BiquadParam_t param = [self getBiquadParam];
    param.freq = freq;
    [self setBiquadParam:param];
}

- (double) getFreqPercent {
    BiquadParam_t param = [self getBiquadParam];
    return (log10(param.freq) - log10(_minFreq)) / (log10(_maxFreq) - log10(_minFreq));
}

- (void) setFreqPercent:(double)percent {
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    double freq = pow(10, percent * (log10(_maxFreq) - log10(_minFreq)) + log10(_minFreq));
    [self setFreq:freq];
}

- (float) getQ {
    BiquadParam_t param = [self getBiquadParam];
    return param.qFac;
}

- (void) setQ:(float)q {
    BiquadParam_t param = [self getBiquadParam];
    param.qFac = q;
    [self setBiquadParam:param];
}

- (float) getDbVol {
    BiquadParam_t param = [self getBiquadParam];
    return param.dbVolume;
}

- (void) setDbVol:(float)vol {
    BiquadParam_t param = [self getBiquadParam];
    param.dbVolume = vol;
    [self setBiquadParam:param];
}

- (void) setBiquadParam:(BiquadParam_t) param {
    float w0 = 2 * M_PI * (float)param.freq / FS;
    float ampl;
    float bandwidth = 1.41f;
    float alpha, a0;
    
    float s = sinf(w0), c = cosf(w0);
    
    [self checkBiquadParamBorder:param];
    
    if (param.order == BIQUAD_ORDER_2){
        switch (param.type){
            case BIQUAD_LOWPASS:
                alpha = s / (2 * param.qFac);
                a0 =  1 + alpha;
                _coef.a1 =  2 * c / (a0);
                _coef.a2 =  (1 - alpha) / (-a0);
                _coef.b0 =  (1 - c) / (2 * a0);
                _coef.b1 =  (1 - c) / a0;
                _coef.b2 =  (1 - c) / (2 * a0);
                break;
            case BIQUAD_HIGHPASS:
                alpha = s / (2 * param.qFac);
                a0 =  1 + alpha;
                _coef.a1 =  2 * c / (a0);
                _coef.a2 =  (1 - alpha) / (-a0);
                _coef.b0 =  (1 + c) / (2 * a0);
                _coef.b1 =  (1 + c) / (-a0);
                _coef.b2 =  (1 + c) / (2 * a0);
                break;
            case BIQUAD_PARAMETRIC:
                ampl = powf(10, param.dbVolume / 40);
                alpha = s / (2 * param.qFac);
                a0 =  1 + alpha / ampl;
                _coef.a1 =  2 * c / a0;
                _coef.a2 =  (1 - alpha / ampl) / (-a0);
                _coef.b0 =  (1 + alpha * ampl) / a0;
                _coef.b1 =  (2 * c) / (-a0);
                _coef.b2 =  (1 - alpha * ampl) / a0;
                break;
            case BIQUAD_ALLPASS:
                alpha = s / (2 * param.qFac);
                a0 =   1 + alpha;
                _coef.a1 =  2 * c / (a0);
                _coef.a2 =  (1 - alpha) / (-a0);
                _coef.b0 =  (1 - alpha) / a0;
                _coef.b1 =  2 * c / (-a0);
                _coef.b2 =  (1 + alpha) / a0;
                break;
            case BIQUAD_BANDPASS:
                //ln(2) / 2 = 0.3465735902
                alpha = s * sinh( 0.3465735902 * bandwidth * w0 / s);
                
                a0 =   1 + alpha;
                _coef.a1 =   2 * c / a0;
                _coef.a2 =   (1 - alpha) / (-a0);
                _coef.b0 =   alpha / a0;
                _coef.b1 =   0;
                _coef.b2 =  -alpha / a0;
                break;
            case BIQUAD_DISABLED:
                _coef.b0 =  1.0f;
                _coef.b1 =  0.0f;
                _coef.b2 =  0.0f;
                _coef.a1 =  0.0f;
                _coef.a2 =  0.0f;
                break;
            default:
                break;
        }
    } else {//order == BIQUAD_ORDER_1
        switch (param.type){
            case BIQUAD_LOWPASS:
                _coef.a1 = pow(2.7, -w0);
                _coef.b0 = 1.0 - _coef.a1;
                break;
            case BIQUAD_HIGHPASS:
                _coef.a1 = pow(2.7, -w0);
                _coef.b0 = _coef.a1;
                _coef.b1 = -_coef.a1;
                break;
            case BIQUAD_ALLPASS:
                _coef.a1 = pow(2.7, -w0);
                _coef.b0 = -_coef.a1;
                _coef.b1 = 1.0;
                break;
            case BIQUAD_DISABLED:
                _coef.b0 =  1.0f;
                _coef.b1 =  0.0f;
                _coef.b2 =  0.0f;
                _coef.a1 =  0.0f;
                _coef.a2 =  0.0f;
                break;
            default:
                break;
        }
        
    }
}

- (BiquadParam_t) getBiquadParam {
    BiquadParam_t param;
    
    param.order = [self getOrder];
    param.type = [self getType];
    
    float arg, w0;
    
    if (param.order == BIQUAD_ORDER_2){
        //if correct read b0, b1, b2, a1, a2 then
        switch (param.type){
            case BIQUAD_LOWPASS:
                arg = 2 * _coef.b1 / _coef.a1 + 1;
                if ((arg < 1.0f) && (arg > -1.0f)) break;
                
                w0 = acos(1.0f / arg);
                param.freq = round(w0 * FS / (2 * M_PI));
                param.qFac = sin(w0) * _coef.a1 / (2 * (2 * cos(w0) - _coef.a1));
                break;
                
            case BIQUAD_HIGHPASS:
                arg = 2 * _coef.b1 / _coef.a1 + 1;
                if ((arg < 1.0f) && (arg > -1.0f)) break;
                
                w0 = acos(-1.0f / arg);
                param.freq = round(w0 * FS / (2 * M_PI));
                param.qFac = sin(w0) * _coef.a1 / (2 * (2 * cos(w0) - _coef.a1));
                break;
                
            case BIQUAD_PARAMETRIC:
                arg = _coef.a1 / (_coef.b0 + _coef.b2);
                if ((arg > 1.0f) || (arg < -1.0f)) break;
                
                w0 = acos(arg);
                param.freq = round(w0 * FS / (2 * M_PI));
                
                arg = (_coef.b0 * 2 * cos(w0) - _coef.a1) / (2 * cos(w0) - _coef.a1);
                if (arg < 0.0) break;
                
                float ampl = sqrt(arg);
                param.dbVolume = 40 * log10(ampl);
                
                float alpha = (2 * cos(w0) / _coef.a1 - 1) * ampl;
                param.qFac = sin(w0) / (2 * alpha);
                break;
                
            case BIQUAD_ALLPASS:
                arg = _coef.a1 / (_coef.b0 + 1);
                if ((arg > 1.0f) || (arg < -1.0f)) break;
                
                w0 = acos(arg);
                param.freq = round(w0 * FS / (2 * M_PI));
                param.qFac = sin(w0) * _coef.a1 / (2 * (2 * cos(w0) - _coef.a1));
                break;
                
            case BIQUAD_BANDPASS:
                w0 = acos(_coef.a1 / 2 * (1 + _coef.b0 / (1 - _coef.b0)));
                param.freq = w0 * (float)FS / (2 * M_PI);
                //TODO set import bandwidth
                break;
                
            case BIQUAD_DISABLED:
            case BIQUAD_USER:
            default:
                break;
        }
    } else {//BIQUAD_ORDER_1
        
        if (_coef.a1 > 0) {
            w0 = -log10(_coef.a1) / log10(2.7);
            param.freq = round(w0 * FS / (2 * M_PI));
        }
    }
    
    return param;
}

- (void) checkBiquadParamBorder:(BiquadParam_t)param {
    if (param.freq > self.maxFreq) param.freq = self.maxFreq;
    if (param.freq < self.minFreq) param.freq = self.minFreq;
    
    if (param.qFac > self.maxQ) param.qFac = self.maxQ;
    if (param.qFac < self.minQ) param.qFac = self.minQ;
    
    if (param.dbVolume > self.maxDbVol) param.dbVolume = self.maxDbVol;
    if (param.dbVolume < self.minDbVol) param.dbVolume = self.minDbVol;
}

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq {
    self.maxFreq = maxFreq;
    self.minFreq = minFreq;
}

- (void) setBorderMaxQ:(double)maxQ minQfac:(double)minQ {
    self.maxQ = maxQ;
    self.minQ = minQ;
}

- (void) setBorderMaxDbVol:(double)maxDbVol minDbVolume:(double)minDbVol {
    self.maxDbVol = maxDbVol;
    self.minDbVol = minDbVol;
}

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQ:(double)maxQ minQ:(double)minQ
              maxDbVol:(double)maxDbVol minDbVol:(double)minDbVol {
    [self setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self setBorderMaxQ:maxQ minQfac:minQ];
    [self setBorderMaxDbVol:maxDbVol minDbVolume:minDbVol];
}

//info string
-(NSString *)getInfo
{
    BiquadParam_t param = [self getBiquadParam];
    
    if ( (param.type != BIQUAD_DISABLED) && (param.type != BIQUAD_USER) ) {
        return [NSString stringWithFormat:@"%dHz Q:%0.2f dB:%0.1f", param.freq, param.qFac, param.dbVolume];
    } else if (param.type == BIQUAD_USER) {
        
        return [NSString stringWithFormat:@"b0:%f b1:%f b2:%f a1:%f a2:%f", _coef.b0, _coef.b1, _coef.b2, _coef.a1, _coef.a2];
    }
    return @"Biquad Disabled.";
}


//send packet to
- (void) sendWithResponse:(BOOL)response
{
    BiquadPacket_t packet;
    
    packet.addr[0]          = self.address0;
    packet.addr[1]          = self.address1;
    packet.biquad           = [self getBiquadParam];
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(BiquadPacket_t)];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

/*===========================================================================
 Get Binary Operations
 ==========================================================================*/
//get binary for save to dsp
- (NSData *) getBinary
{
    
    DataBufHeader_t dataBufHeader;
    dataBufHeader.addr = self.address0;
    dataBufHeader.length = 20;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
    
    Number523_t coefs[5] = {to523Reverse(_coef.b0), to523Reverse(_coef.b1), to523Reverse(_coef.b2),
                            to523Reverse(_coef.a1), to523Reverse(_coef.a2)};
    [data appendBytes:coefs length:20];
    
    if (self.address1) {
        dataBufHeader.addr = self.address1;
        [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
        [data appendBytes:coefs length:20];
    }
    
    return data;
}

- (BOOL) importData:(NSData *)data{
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == self.address0) && (dataBufHeader->length == 20)){
            
            Number523_t * number = (Number523_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            _coef.b0 = _523toFloat(reverseNumber523(number[0]));
            _coef.b1 = _523toFloat(reverseNumber523(number[1]));
            _coef.b2 = _523toFloat(reverseNumber523(number[2]));
            _coef.a1 = _523toFloat(reverseNumber523(number[3]));
            _coef.a2 = _523toFloat(reverseNumber523(number[4]));
            
            return YES;
        }
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t) + dataBufHeader->length);
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"MaxFreq" withIntValue:self.maxFreq];
    [xmlData addElementWithName:@"MinFreq" withIntValue:self.minFreq];
    [xmlData addElementWithName:@"MaxQ" withDoubleValue:self.maxQ];
    [xmlData addElementWithName:@"MinQ" withDoubleValue:self.minQ];
    [xmlData addElementWithName:@"MaxDbVol" withDoubleValue:self.maxDbVol];
    [xmlData addElementWithName:@"MinDbVol" withDoubleValue:self.minDbVol];
    
    BiquadParam_t param = [self getBiquadParam];
    
    [xmlData addElementWithName:@"Order" withIntValue:param.order];
    [xmlData addElementWithName:@"Type" withIntValue:param.type];
    [xmlData addElementWithName:@"Freq" withIntValue:param.freq];
    [xmlData addElementWithName:@"Q" withDoubleValue:param.qFac];
    [xmlData addElementWithName:@"DbVol" withDoubleValue:param.dbVolume];
    
    
    XmlData * biquadXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address0] stringValue], @"Address0",
                           [[NSNumber numberWithInt:self.address1] stringValue], @"Address1", nil];
    
    
    [biquadXmlData addElementWithName:@"Biquad" withXmlValue:xmlData withAttrib:dict];
    
    return biquadXmlData;
    
}

-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict {
    count = 0;
    [xmlParser pushDelegate:self];
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void) didFindXmlElement:(NSString *)elementName
                attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
                    parser:(XmlParserWrapper *)xmlParser {
    
}

- (void) didFoundXmlCharacters:(NSString *)string
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Order"]){
        [self setOrder:[string intValue]];
        count++;
    }
    if ([elementName isEqualToString:@"Type"]){
        [self setType:[string intValue]];
        count++;
    }
    if ([elementName isEqualToString:@"Freq"]){
        [self setFreq:[string intValue]];
        count++;
    }
    if ([elementName isEqualToString:@"Q"]){
        [self setQ:[string doubleValue]];
        count++;
    }
    if ([elementName isEqualToString:@"DbVol"]){
        [self setDbVol:[string doubleValue]];
        count++;
    }
    
    if ([elementName isEqualToString:@"MaxFreq"]){
        self.maxFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinFreq"]){
        self.minFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"MaxQ"]){
        self.maxQ = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinQ"]){
        self.minQ = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MaxDbVol"]){
        self.maxDbVol = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinDbVol"]){
        self.minDbVol = [string doubleValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Biquad"]){
        if (count != 11){
            xmlParser.error = [NSString stringWithFormat:
                               @"Biquad=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.address0] stringValue] ];
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}
@end
