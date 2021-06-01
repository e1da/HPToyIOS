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

#import "Filters.h"

@interface HiFiToyPreset : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property NSString * presetName;
@property uint16_t checkSum;

// HiFiToy CHARACTERISTICS
@property (nonatomic) Filters *             filters;
@property (nonatomic) Volume *              masterVolume;
@property (nonatomic) BassTreble *          bassTreble;
@property (nonatomic) Loudness *            loudness;
@property (nonatomic) Drc *                 drc;

+ (HiFiToyPreset *) getDefault;

- (BOOL)rename:(NSString *)newName;

- (void) storeToPeripheral;
- (void) importFromPeripheral;

- (void) updateChecksum;
- (void) updateChecksumWithParamData:(NSData *)data;

- (BOOL) importFromXml:(NSURL *)url checkName:(BOOL)checkName
         resultHandler:(void (^)(HiFiToyPreset *, NSString *))resultHandler;

- (BOOL) importFromXmlWithData:(NSData *)data
                      withName:(NSString *)name
                     checkName:(BOOL)checkName
                 resultHandler:(void (^)(HiFiToyPreset *, NSString *))resultHandler;

@end
