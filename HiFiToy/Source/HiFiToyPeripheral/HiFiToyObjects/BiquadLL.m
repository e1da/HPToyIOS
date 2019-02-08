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

- (id) init {
    self = [super init];
    if (self) {
        self.biquadParam = [[BiquadParam alloc] init];
        self.biquadParam.delegate = self;
        self.hiddenGui = NO;
        self.enabled = YES;
        self.order = BIQUAD_ORDER_2;
        self.type = BIQUAD_OFF;
    }
    return self;
}

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
 
    [encoder encodeBool:self.hiddenGui forKey:@"keyHiddenGui"];
    
    [encoder encodeInt:self.address0 forKey:@"keyAddress0"];
    [encoder encodeInt:self.address1 forKey:@"keyAddress1"];
    
    [encoder encodeInt:self.order forKey:@"keyOrder"];
    [encoder encodeInt:self.type forKey:@"keyType"];
    [encoder encodeBytes:(uint8_t *)&_coef length:sizeof(BiquadCoef_t) forKey:@"keyCoef"];
    
    BiquadParamBorder_t b = self.biquadParam.border;
    [encoder encodeInt:b.maxFreq forKey:@"keyMaxFreq"];
    [encoder encodeInt:b.minFreq forKey:@"keyMinFreq"];
    [encoder encodeFloat:b.maxQ forKey:@"keyMaxQ"];
    [encoder encodeFloat:b.minQ forKey:@"keyMinQ"];
    [encoder encodeFloat:b.maxDbVol forKey:@"keyMaxDbVol"];
    [encoder encodeFloat:b.minDbVol forKey:@"keyMinDbVol"];
}

- (BiquadLL *) initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _hiddenGui = [decoder decodeBoolForKey:@"keyHiddenGui"];
        _enabled = YES;
        
        self.address0 = [decoder decodeIntForKey:@"keyAddress0"];
        self.address1 = [decoder decodeIntForKey:@"keyAddress1"];
        
        _order = [decoder decodeIntForKey:@"keyOrder"];
        _type = [decoder decodeIntForKey:@"keyType"];
        
        NSUInteger size = sizeof(BiquadCoef_t);
        const uint8_t * p = [decoder decodeBytesForKey:@"keyCoef" returnedLength:&size];
        memcpy(&_coef, p, size);
        
        BiquadParamBorder_t b;
        b.maxFreq = [decoder decodeIntForKey:@"keyMaxFreq"];
        b.minFreq = [decoder decodeIntForKey:@"keyMinFreq"];
        b.maxQ = [decoder decodeFloatForKey:@"keyMaxQ"];
        b.minQ = [decoder decodeFloatForKey:@"keyMinQ"];
        b.maxDbVol = [decoder decodeFloatForKey:@"keyMaxDbVol"];
        b.minDbVol = [decoder decodeFloatForKey:@"keyMinDbVol"];
        
        _biquadParam = [BiquadParam initWithCoef:_coef withBorder:b withOrder:self.order withType:_type];
        _biquadParam.delegate = self;
        
    }
    
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(BiquadLL *)copyWithZone:(NSZone *)zone {
    BiquadLL * copyBiquad = [[[self class] allocWithZone:zone] init];
    
    copyBiquad.hiddenGui = self.hiddenGui;
    copyBiquad.enabled = self.enabled;
    
    copyBiquad.address0 = self.address0;
    copyBiquad.address1 = self.address1;
    copyBiquad.order = self.order;
    copyBiquad.type = self.type;
    copyBiquad.coef = self.coef; //copy biquad param too
    copyBiquad.biquadParam = [self.biquadParam copy];
    
    return copyBiquad;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    
    if ([object isKindOfClass:[BiquadLL class]]) {
        BiquadLL * temp = object;
        BiquadParamBorder_t bTemp = temp.biquadParam.border;
        BiquadParamBorder_t b = self.biquadParam.border;
        
        if ((self.address0 == temp.address0) &&
            (self.address1 == temp.address1) &&
            (self.order == temp.order) &&
            (self.type == temp.type) &&
            (isBiquadCoefEqual(self.coef, temp.coef)) &&
            
            (b.maxFreq == b.maxFreq) &&
            (b.minFreq == b.minFreq) &&
            (isFloatDiffLessThan(b.maxQ, bTemp.maxQ, 0.01f)) &&
            (isFloatDiffLessThan(b.minQ, bTemp.minQ, 0.01f)) &&
            (isFloatDiffLessThan(b.maxDbVol, bTemp.maxDbVol, 0.01f)) &&
            (isFloatDiffLessThan(b.minDbVol, bTemp.minDbVol, 0.01f)) ) {
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
    
    return currentInstance;
}

- (uint8_t)address {
    return self.address0;
    
}

- (void) updateOrder {
    if ( (isFloatNull(_coef.b2)) && (isFloatNull(_coef.a2)) && (!isFloatNull(_coef.b0)) && (!isFloatNull(_coef.b1)) && (!isFloatNull(_coef.a1)) ) {
        _order = BIQUAD_ORDER_1;
    } else {
        _order = BIQUAD_ORDER_2;
    }
}

//setters/getters
- (void) setOrder:(BiquadOrder_t)order {
    _order = order;
    [self didUpdateBiquadParam:self.biquadParam];
}

- (void) setType:(BiquadType_t)type {
    _type = type;
    [self didUpdateBiquadParam:self.biquadParam];
}


- (void) setCoef:(BiquadCoef_t)coef {
    _coef = coef;
 
    checkFloatFor523(&_coef.b0);
    checkFloatFor523(&_coef.b1);
    checkFloatFor523(&_coef.b2);
    checkFloatFor523(&_coef.a1);
    checkFloatFor523(&_coef.a2);
    
    [self.biquadParam updateWithCoef:coef withOrder:self.order withType:self.type];
}


- (void) didUpdateBiquadParam:(BiquadParam *) param {
    float w0 = 2 * M_PI * (float)param.freq / FS;
    float ampl;
    float bandwidth = 1.41f;
    float alpha, a0;
    
    if (self.type == BIQUAD_USER) return;
    
    float s = sinf(w0), c = cosf(w0);
    
    if (self.order == BIQUAD_ORDER_2){
        switch (self.type){
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
            case BIQUAD_OFF:
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
        _coef.a2 = 0;
        _coef.b2 = 0;
        
        switch (self.type){
            case BIQUAD_LOWPASS:
                _coef.a1 = pow(2.7, -w0);
                _coef.b0 = 1.0 - _coef.a1;
                //WARNING b1 = ???
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
            case BIQUAD_OFF:
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

/* ------------------ math --------------------*/
- (double) getAFR:(double)freqX {
    if ( (!self.hiddenGui) && (self.enabled) && (self.order == BIQUAD_ORDER_2) ) {

        switch (self.type) {
            case BIQUAD_LOWPASS:
                return [self.biquadParam get_LPF:freqX];
                
            case BIQUAD_HIGHPASS:
                return [self.biquadParam get_HPF:freqX];
                
            case BIQUAD_PARAMETRIC:
                return [self.biquadParam get_PeakingEQ:freqX];
                
            case BIQUAD_OFF:
                return 1.0f;
            default:
                return 1.0f;
        }
    }
    return 1.0;
}

//info string
-(NSString *)getInfo {
    if (self.enabled) {
        switch (self.type) {
            case BIQUAD_LOWPASS:
            case BIQUAD_HIGHPASS:
            case BIQUAD_BANDPASS:
            case BIQUAD_ALLPASS:
                return [NSString stringWithFormat:@"%dHz", self.biquadParam.freq];
                
            case BIQUAD_PARAMETRIC:
                return [NSString stringWithFormat:@"%dHz Q:%0.2f dB:%0.1f", self.biquadParam.freq,
                        self.biquadParam.qFac, self.biquadParam.dbVolume];
                
            case BIQUAD_USER:
                return [NSString stringWithFormat:@"b0:%f b1:%f b2:%f a1:%f a2:%f", _coef.b0, _coef.b1, _coef.b2, _coef.a1, _coef.a2];
                
            case BIQUAD_OFF:
                return @"Biquad off.";
                
        }
    }
    return @"Biquad disabled.";
}


//send packet to
- (void) sendCoefWithResponse:(BOOL)response {
    BiquadCoefPacket_t packet;
    packet.addr.ch0 = self.address0;
    packet.addr.ch1 = self.address1;
    packet.bCoef    = self.coef;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(BiquadCoefPacket_t)];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:YES];
}

- (void) sendBiquadWithResponse:(BOOL)response {
    BiquadPacket_t packet;
     
    packet.addr.ch0          = self.address0;
    packet.addr.ch1          = self.address1;
     
    if (self.enabled) {
        packet.biquad.order     = self.order;
        packet.biquad.type      = self.type;
        packet.biquad.freq      = self.biquadParam.freq;
        packet.biquad.qFac      = self.biquadParam.qFac;
        packet.biquad.dbVolume  = self.biquadParam.dbVolume;
     
    } else {
        packet.biquad.order     = BIQUAD_ORDER_2;
        packet.biquad.type      = BIQUAD_OFF;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(BiquadPacket_t)];
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

- (void) sendWithResponse:(BOOL)response
{
    if (self.type == BIQUAD_USER) {
        [self sendCoefWithResponse:response];
    } else {
        [self sendBiquadWithResponse:response];
    }
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
            
            [self updateOrder];
            [self.biquadParam updateWithCoef:_coef withOrder:self.order withType:self.type];
            return YES;
        }
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t) + dataBufHeader->length);
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    BiquadParamBorder_t b = _biquadParam.border;
    
    [xmlData addElementWithName:@"HiddenGui" withIntValue:self.hiddenGui];
    [xmlData addElementWithName:@"Order" withIntValue:self.order];
    [xmlData addElementWithName:@"Type" withIntValue:self.type];
    
    [xmlData addElementWithName:@"MaxFreq" withIntValue:b.maxFreq];
    [xmlData addElementWithName:@"MinFreq" withIntValue:b.minFreq];
    [xmlData addElementWithName:@"MaxQ" withDoubleValue:b.maxQ];
    [xmlData addElementWithName:@"MinQ" withDoubleValue:b.minQ];
    [xmlData addElementWithName:@"MaxDbVol" withDoubleValue:b.maxDbVol];
    [xmlData addElementWithName:@"MinDbVol" withDoubleValue:b.minDbVol];
    
    [xmlData addElementWithName:@"B0" withDoubleValue:_coef.b0];
    [xmlData addElementWithName:@"B1" withDoubleValue:_coef.b1];
    [xmlData addElementWithName:@"B2" withDoubleValue:_coef.b2];
    [xmlData addElementWithName:@"A1" withDoubleValue:_coef.a1];
    [xmlData addElementWithName:@"A2" withDoubleValue:_coef.a2];
    
    XmlData * biquadXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address0] stringValue], @"Address",
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
    
    if ([elementName isEqualToString:@"HiddenGui"]){
        self.hiddenGui = [string boolValue];
        count++;
    }
    
    if ([elementName isEqualToString:@"Order"]){
        _order = [string intValue];
        count++;
    }
    
    if ([elementName isEqualToString:@"Type"]){
        _type = [string intValue];
        count++;
    }
    
    if ([elementName isEqualToString:@"B0"]){
        _coef.b0 = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"B1"]){
        _coef.b1 = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"B2"]){
        _coef.b2 = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"A1"]){
        _coef.a1 = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"A2"]){
        _coef.a2 = [string floatValue];
        count++;
    }
    
    BiquadParamBorder_t b = _biquadParam.border;

    if ([elementName isEqualToString:@"MaxFreq"]){
        b.maxFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinFreq"]){
        b.minFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"MaxQ"]){
        b.maxQ = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinQ"]){
        b.minQ = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MaxDbVol"]){
        b.maxDbVol = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinDbVol"]){
        b.minDbVol = [string doubleValue];
        count++;
    }
    
    _biquadParam.border = b;
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Biquad"]){
        if (count != 14){
            xmlParser.error = [NSString stringWithFormat:
                               @"Biquad=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.address0] stringValue] ];
        } else {
            [_biquadParam updateWithCoef:_coef withOrder:self.order withType:self.type];
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}
@end
