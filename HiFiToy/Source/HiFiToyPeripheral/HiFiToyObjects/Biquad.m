//
//  Biquad.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "Biquad.h"
#import "Number523.h"

@interface Biquad(){
    int count;
}

// Math Calculation
- (BOOL) doubleCompare:(double)arg0 withDouble:(double)arg1;

- (double) get_LPF:(double)freqX;
- (double) get_HPF:(double)freqX;
- (double) get_PeakingEQ:(double)freqX;

@end


@implementation Biquad

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init
{
    self = [super init];
    if (self){
        [self setBorderMaxFreq:30000 minFreq:10
                       maxQfac:10.0f minQfac:0.1f
                   maxDbVolume:15.0f minDbVolume:-40.0f];
        
    }
    
    return self;
}

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.address forKey:@"keyAddress"];
    
    [encoder encodeInt:self.maxFreq forKey:@"keyMaxFreq"];
    [encoder encodeInt:self.minFreq forKey:@"keyMinFreq"];
    [encoder encodeDouble:self.maxQfac forKey:@"keyMaxQfac"];
    [encoder encodeDouble:self.minQfac forKey:@"keyMinQfac"];
    [encoder encodeDouble:self.maxDbVolume forKey:@"keyMaxDbVolume"];
    [encoder encodeDouble:self.minDbVolume forKey:@"keyMinDbVolume"];
    
    [encoder encodeInt:self.order forKey:@"keyOrder"];
    [encoder encodeInt:self.type forKey:@"keyType"];
    [encoder encodeInt:self.freq forKey:@"keyFreq"];
    [encoder encodeDouble:self.qFac forKey:@"keyQFac"];
    [encoder encodeDouble:self.dbVolume forKey:@"keyDbVolume"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.address = [decoder decodeIntForKey:@"keyAddress"];
        
        self.maxFreq = [decoder decodeIntForKey:@"keyMaxFreq"];
        self.minFreq = [decoder decodeIntForKey:@"keyMinFreq"];
        self.maxQfac = [decoder decodeDoubleForKey:@"keyMaxQfac"];
        self.minQfac = [decoder decodeDoubleForKey:@"keyMinQfac"];
        self.maxDbVolume = [decoder decodeDoubleForKey:@"keyMaxDbVolume"];
        self.minDbVolume = [decoder decodeDoubleForKey:@"keyMinDbVolume"];
        
        self.order = [decoder decodeIntForKey:@"keyOrder"];
        self.type = [decoder decodeIntForKey:@"keyType"];
        self.freq = [decoder decodeIntForKey:@"keyFreq"];
        self.qFac = [decoder decodeDoubleForKey:@"keyQFac"];
        self.dbVolume = [decoder decodeDoubleForKey:@"keyDbVolume"];
        
    }
    return self;
}


/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(Biquad *)copyWithZone:(NSZone *)zone
{
    Biquad * copyBiquad = [[[self class] allocWithZone:zone] init];
    
    copyBiquad.address = self.address;
    
    copyBiquad.maxFreq = self.maxFreq;
    copyBiquad.minFreq = self.minFreq;
    copyBiquad.maxQfac = self.maxQfac;
    copyBiquad.minQfac = self.minQfac;
    copyBiquad.maxDbVolume = self.maxDbVolume;
    copyBiquad.minDbVolume = self.minDbVolume;
    
    copyBiquad.order = self.order;
    copyBiquad.type = self.type;
    copyBiquad.freq = self.freq;
    copyBiquad.qFac = self.qFac;
    copyBiquad.dbVolume = self.dbVolume;
    
    return copyBiquad;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        Biquad * temp = object;
        
        if ((self.address == temp.address) &&
            (self.order == temp.order) &&
            (self.type == temp.type) &&
            (self.freq == temp.freq) &&
            (fabs(self.qFac - temp.qFac) < 0.02f) &&
            (fabs(self.dbVolume - temp.dbVolume)  < 0.02f) &&
            
            (self.maxFreq == temp.maxFreq) &&
            (self.minFreq == temp.minFreq) &&
            (fabs(self.maxQfac - temp.maxQfac) < 0.02f) &&
            (fabs(self.minQfac - temp.minQfac) < 0.02f) &&
            (fabs(self.maxDbVolume - temp.maxDbVolume) < 0.02f) &&
            (fabs(self.minDbVolume - temp.minDbVolume) < 0.02f)){
            return YES;
        }
    }
    
    
    return NO;
}

/*---------------------- create method -----------------------------*/
+ (Biquad *)initWithAddress:(int)address
                      Order:(BiquadOrder_t)order
                       Type:(BiquadType_t)type
                       Freq:(int)freq
                       Qfac:(double)qFac
                   dbVolume:(double) dbVolume
{
    Biquad *currentInstance = [[Biquad alloc] init];
    
    currentInstance.address = address;
    
    currentInstance.order = order;
    currentInstance.type = type;
    currentInstance.freq = freq;
    currentInstance.qFac = qFac;
    currentInstance.dbVolume = dbVolume;
    
    return currentInstance;
}

/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (BOOL) doubleCompare:(double)arg0 withDouble:(double)arg1
{
    if (fabs(arg0 - arg1) < 0.02f){
        return YES;
    } else {
        return NO;
    }
}

- (double) get_LPF:(double)freqX
{
    return sqrt(1.0f/(  pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (self.freq * self.qFac), 2)    ));
}

- (double) get_HPF:(double)freqX
{
    return sqrt(pow( pow(freqX / self.freq , 4) - pow(freqX / self.freq, 2) , 2) +
                pow(freqX / self.freq, 6) / pow(self.qFac, 2))
    / (pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (self.qFac * self.freq), 2));
}

- (double) get_PeakingEQ:(double)freqX
{
    double Ampl = pow(10, self.dbVolume / 40);
    double A1 = pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (self.qFac * self.freq), 2);
    double A2 = (1 - pow(freqX / self.freq, 2)) *
    (freqX * Ampl / (self.qFac * self.freq) - freqX / (Ampl * self.qFac * self.freq));
    
    double B = pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (Ampl * self.qFac * self.freq), 2);
    
    
    return  sqrt(pow(A1, 2) + pow(A2, 2)) / B;
}

- (double) getAFR:(double)freqX
{
    if (self.order == BIQUAD_ORDER_2) {
        switch (self.type) {
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

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
{
    self.maxFreq = maxFreq;
    self.minFreq = minFreq;
}

- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac
{
    self.maxQfac = maxQfac;
    self.minQfac = minQfac;
}

- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume
{
    self.maxDbVolume = maxDbVolume;
    self.minDbVolume = minDbVolume;
}

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume
{
    [self setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self setBorderMaxQfac:maxQfac minQfac:minQfac];
    [self setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
}

- (void) setFreq:(int)freq {
    
    _freq = freq;
    
    if (_freq > self.maxFreq) _freq = self.maxFreq;
    if (_freq < self.minFreq) _freq = self.minFreq;
    
}

- (int) getFreq {
    return _freq;
}

- (void) setFreqPercent:(double)percent {
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    double freq = pow(10, percent * (log10(_maxFreq) - log10(_minFreq)) + log10(_minFreq));
    [self setFreq:freq];
}
- (double) getFreqPercent {
    return (log10(_freq) - log10(_minFreq)) / (log10(_maxFreq) - log10(_minFreq));
}

- (void) setQFac:(double)qfac
{
    _qFac = qfac;
    
    if (_qFac > self.maxQfac) _qFac = self.maxQfac;
    if (_qFac < self.minQfac) _qFac = self.minQfac;
}

- (double) getQFac
{
    return _qFac;
}

- (void) setDbVolume:(double)dbvolume
{
    _dbVolume = dbvolume;
    
    if (_dbVolume > self.maxDbVolume) _dbVolume = self.maxDbVolume;
    if (_dbVolume < self.minDbVolume) _dbVolume = self.minDbVolume;
}

- (double) getDbVolume
{
    return _dbVolume;
}

- (void) setBiquad:(Biquad*)biquad
{
    if (!biquad) return;

    self.maxFreq = biquad.maxFreq;
    self.minFreq = biquad.minFreq;
    self.maxQfac = biquad.maxQfac;
    self.minQfac = biquad.minQfac;
    self.maxDbVolume = biquad.maxDbVolume;
    self.minDbVolume = biquad.minDbVolume;
    
    self.order = biquad.order;
    self.type = biquad.type;
    self.freq = biquad.freq;
    self.qFac = biquad.qFac;
    self.dbVolume = biquad.dbVolume;
    
}

//info string
-(NSString *)getInfo
{
    if (self.type != BIQUAD_DISABLED){
        return [NSString stringWithFormat:@"%dHz Q:%0.2f dB:%0.1f", self.freq, self.qFac, self.dbVolume];
    }
    return @"Biquad Disabled.";
}


//send packet to
- (void) sendWithResponse:(BOOL)response
{
    BiquadPacket_t packet;
    
    packet.addr             = self.address;
    packet.biquad.order     = self.order;
    packet.biquad.type      = self.type;
    packet.biquad.q         = self.qFac;
    packet.biquad.freq      = self.freq;
    packet.biquad.volume    = self.dbVolume;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(BiquadPacket_t)];
    
    //send data
    //[[DSPControl sharedInstance] sendDataToDsp:data withResponse:response];
}

/*===========================================================================
 Get Binary Operations
 ==========================================================================*/
//get binary for save to dsp
- (NSData *) getBinary
{
    double w0 = 2 * M_PI * (float)self.freq / FS;
    double ampl;// = pow(10, dbBoost / 40);
    double gainLinear = 1;//0^(gain/20);
    double bandwidth = 1.41;
    double alpha, a0, a1 = 0, a2 = 0, b0 = 0, b1 = 0, b2 = 0;

    double s = sin(w0), c = cos(w0);
    
    if (self.order == BIQUAD_ORDER_2){
        switch (self.type){
            case BIQUAD_LOWPASS:
                alpha = s / (2 * self.qFac);
                a0 =   1.0 + alpha;
                a1 =  2 * c / (a0);
                a2 =   (1.0 - alpha) / (-a0);
                b0 =  (1.0 - c) * gainLinear / (2 * a0);
                b1 =  (1.0 - c)  * gainLinear / a0;
                b2 =  (1.0 - c) * gainLinear / (2 * a0);
                break;
            case BIQUAD_HIGHPASS:
                alpha = s / (2 * self.qFac);
                a0 =   1.0 + alpha;
                a1 =  2 * c / (a0);
                a2 =   (1.0 - alpha) / (-a0);
                b0 =  (1.0 + c) * gainLinear / (2 * a0);
                b1 =  -1*(1.0 + c)  * gainLinear / a0;
                b2 =  (1.0 + c) * gainLinear / (2 * a0);
                break;
            case BIQUAD_PARAMETRIC:
                ampl = pow(10, self.dbVolume / 40);
                alpha = s / (2 * self.qFac);
                a0 =  1 + alpha / ampl;
                a1 =  2 * c / a0;
                a2 =  (1 - alpha / ampl) / (-a0);
                b0 =  (1 + alpha * ampl) * gainLinear / a0;
                b1 = -(2 * c) * gainLinear / a0;
                b2 =  (1 - alpha * ampl) * gainLinear / a0;
                break;
            case BIQUAD_ALLPASS:
                alpha = s / (2 * self.qFac);
                a0 =   1.0 + alpha;
                a1 =  2 * c / (a0);
                a2 =   (1.0 - alpha) / (-a0);
                b0 =  (1.0 - alpha) * gainLinear / a0;
                b1 =  -2 * c * gainLinear / a0;
                b2 =  (1.0 + alpha) * gainLinear / a0;
                break;
            case BIQUAD_BANDPASS:
                //ln(2) / 2 = 0.3465735902
                alpha = s * sinh( 0.3465735902 * bandwidth * w0 / s);
                
                a0 =   1 + alpha;
                a1 =   2 * c / a0;
                a2 =   (1 - alpha) / (-a0);
                b0 =   alpha * gainLinear / a0;
                b1 =   0;
                b2 =  -alpha * gainLinear / a0;
                break;
            case BIQUAD_DISABLED:
            default:
                b0 =  1.0f;
                b1 =  0.0f;
                b2 =  0.0f;
                a1 =  0.0f;
                a2 =  0.0f;
                break;
        }
    } else {//order == BIQUAD_ORDER_1
        switch (self.type){
            case BIQUAD_LOWPASS:
                a1 = pow(2.7, -w0);
                b0 = 1.0 - a1;
                break;
            case BIQUAD_HIGHPASS:
                a1 = pow(2.7, -w0);
                b0 = a1;
                b1 = -a1;
                break;
            case BIQUAD_ALLPASS:
                a1 = pow(2.7, -w0);
                b0 = -a1;
                b1 = 1.0;
                break;
            case BIQUAD_DISABLED:
            default:
                b0 =  1.0f;
                b1 =  0.0f;
                b2 =  0.0f;
                a1 =  0.0f;
                a2 =  0.0f;
                break;
        }
        
    }
    
    DataBufHeader_t dataBufHeader;
    dataBufHeader.addr = self.address;
    dataBufHeader.length = 20;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
    
    Number523_t coefs[5] = {to523(b0), to523(b1), to523(b2), to523(a1), to523(a2)}; // !!!maybe need reverse
    [data appendBytes:coefs length:20];
    
    return data;
}

- (BOOL) importData:(NSData *)data{
    double a1 = 0, a2 = 0, b0 = 0, b1 = 0, b2 = 0;
    double w0, fr, qF, vol;
    
    BOOL importFlag = NO;
    
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == self.address) && (dataBufHeader->length == 20)){
            
            Number523_t * number = (Number523_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            b0 = _523toFloat(number[0]); //!!!maybe need reverse
            b1 = _523toFloat(number[1]);
            b2 = _523toFloat(number[2]);
            a1 = _523toFloat(number[3]);
            a2 = _523toFloat(number[4]);
            
            importFlag = YES;
            break;
        }
        dataBufHeader += sizeof(DataBufHeader_t) + dataBufHeader->length;
    }
    
    if (importFlag == NO) {
        return NO;
    }
    
    if ([self doubleCompare:b0 withDouble:1.0f] &&
        [self doubleCompare:b1 withDouble:0.0f] &&
        [self doubleCompare:b2 withDouble:0.0f] &&
        [self doubleCompare:a2 withDouble:0.0f] &&
        [self doubleCompare:a1 withDouble:0.0f]){
        
        self.type = BIQUAD_DISABLED;
        return YES;
    }
    
    double arg;
    
    if (self.order == BIQUAD_ORDER_2){
        //if correct read b0, b1, b2, a1, a2 then
        switch (self.type){
            case BIQUAD_LOWPASS:
                arg = 2 * b1 / a1 + 1;
                if ((arg < 1.0f) && (arg > -1.0f)) return NO;
                
                w0 = acos(1.0f / arg);
                fr = round(w0 * FS / (2 * M_PI));
                qF = sin(w0) * a1 / (2 * (2 * cos(w0) - a1));
                NSLog(@"Fr comp %d == %d", self.freq, (int)fr);
                NSLog(@"Qf comp %f == %f", self.qFac, qF);
                
                self.freq = fr;
                self.qFac = qF;
                break;
            case BIQUAD_HIGHPASS:
                arg = 2 * b1 / a1 + 1;
                if ((arg < 1.0f) && (arg > -1.0f)) return NO;
                
                w0 = acos(-1.0f / arg);
                fr = round(w0 * FS / (2 * M_PI));
                qF = sin(w0) * a1 / (2 * (2 * cos(w0) - a1));
                NSLog(@"Fr comp %d == %d", self.freq, (int)fr);
                NSLog(@"Qf comp %f == %f", self.qFac, qF);
                
                self.freq = fr;
                self.qFac = qF;
                break;
            case BIQUAD_PARAMETRIC:
                arg = a1 / (b0 + b2);
                if ((arg > 1.0f) || (arg < -1.0f)) return NO;
                
                w0 = acos(arg);
                fr = round(w0 * FS / (2 * M_PI));
                
                arg = (b0 * 2 * cos(w0) - a1) / (2 * cos(w0) - a1);
                if (arg < 0.0) return NO;
                
                float ampl = sqrt(arg);
                vol = 40 * log10(ampl);
                
                float alpha = (2 * cos(w0) / a1 - 1) * ampl;
                qF = sin(w0) / (2 * alpha);
                
                /*Qf = sin(w0) * a1 / (2 * (2 * b0 *cos(w0) - a1));
                 Vol = 20 * log10(sin(w0) * a1 / (2 * Qf * (2 * a2 * cos(w0) + a1)));*/
                NSLog(@"Fr comp %d == %d", self.freq, (int)fr);
                NSLog(@"Qf comp %f == %f", self.qFac, qF);
                NSLog(@"Vol1 comp %f == %f", self.dbVolume, vol);
                
                self.freq = fr;
                self.qFac = qF;
                self.dbVolume = vol;
                break;
            case BIQUAD_ALLPASS:
                arg = a1 / (b0 + 1);
                if ((arg > 1.0f) || (arg < -1.0f)) return NO;
                
                w0 = acos(arg);
                fr = round(w0 * FS / (2 * M_PI));
                qF = sin(w0) * a1 / (2 * (2 * cos(w0) - a1));
                NSLog(@"Fr comp %d == %d", self.freq, (int)fr);
                NSLog(@"Qf comp %f == %f", self.qFac, qF);
                
                self.freq = fr;
                self.qFac = qF;
                break;
            case BIQUAD_BANDPASS:
                w0 = acos(a1 / 2 * (1 + b0 / (1 - b0)));
                self.freq = w0 * (float)FS / (2 * M_PI);
                //TODO set import bandwidth
                break;
                
            case BIQUAD_DISABLED:
            default:
                /*b0 =  1.0f;
                 b1 =  0.0f;
                 b2 =  0.0f;
                 a1 =  0.0f;
                 a2 =  0.0f;*/
                return NO;
                break;
        }
    } else {//BIQUAD_ORDER_1
        if (a1 <= 0.0) return NO;
        
        w0 = -log10(a1) / log10(2.7);
        self.freq = round(w0 * FS / (2 * M_PI));
    }
    
    
    return YES;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"MaxFreq" withIntValue:self.maxFreq];
    [xmlData addElementWithName:@"MinFreq" withIntValue:self.minFreq];
    [xmlData addElementWithName:@"MaxQfac" withDoubleValue:self.maxQfac];
    [xmlData addElementWithName:@"MinQfac" withDoubleValue:self.minQfac];
    [xmlData addElementWithName:@"MaxDbVolume" withDoubleValue:self.maxDbVolume];
    [xmlData addElementWithName:@"MinDbVolume" withDoubleValue:self.minDbVolume];
    
    [xmlData addElementWithName:@"Order" withIntValue:self.order];
    [xmlData addElementWithName:@"Type" withIntValue:self.type];
    [xmlData addElementWithName:@"Freq" withIntValue:self.freq];
    [xmlData addElementWithName:@"Qfac" withDoubleValue:self.qFac];
    [xmlData addElementWithName:@"DbVolume" withDoubleValue:self.dbVolume];
    
    
    XmlData * biquadXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address] stringValue], @"Address", nil];
    
    
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
        self.order = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Type"]){
        self.type = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Freq"]){
        self.freq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Qfac"]){
        self.qFac = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"DbVolume"]){
        self.dbVolume = [string doubleValue];
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
    if ([elementName isEqualToString:@"MaxQfac"]){
        self.maxQfac = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinQfac"]){
        self.minQfac = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MaxDbVolume"]){
        self.maxDbVolume = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinDbVolume"]){
        self.minDbVolume = [string doubleValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Biquad"]){
        if (count != 11){
            xmlParser.error = [NSString stringWithFormat:
                               @"Biquad=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.address] stringValue] ];
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
