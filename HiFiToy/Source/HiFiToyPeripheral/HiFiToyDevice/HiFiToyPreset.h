//
//  HiFiToyPreset.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Volume.h"
#import "BassTreble.h"
#import "Loudness.h"
#import "Drc.h"

@interface HiFiToyPreset : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property NSString * presetName;
@property uint16_t checkSum;


// HiFiToy CHARACTERISTICS
//pointer to all characteristics
@property (nonatomic) NSArray *     characteristics;

@property (nonatomic) Volume *      masterVolume;
@property (nonatomic) BassTreble *  bassTreble;
@property (nonatomic) Loudness *    loudness;
@property (nonatomic) Drc *         drc;

- (void) initCharacteristicsPointer;

+ (HiFiToyPreset *) initDefaultPreset;

- (BOOL)rename:(NSString *)newName;

-(void)saveToHiFiToyPeripheral;

- (void) updateChecksum;
- (void) updateChecksumWithParamData:(NSData *)data;

-(BOOL) importFromXml:(NSURL *)url;

@end
