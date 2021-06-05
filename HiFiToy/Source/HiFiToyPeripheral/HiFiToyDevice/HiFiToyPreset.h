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

@property NSString * _Nonnull presetName;
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

- (BOOL) importFromDataBufs:(NSArray<HiFiToyDataBuf *> *)dataBufs biquadsType:(NSData *) biquadType;

- (void) updateChecksum;

- (BOOL) importFromXml:(NSURL * _Nullable)url
         resultHandler:(void (^ __nullable)(HiFiToyPreset * _Nonnull p, NSString * _Nullable error))resultHandler;

- (BOOL) importFromXmlWithData:(NSData * _Nonnull)data
                      withName:(NSString * _Nonnull)name
                 resultHandler:(void (^ __nullable)(HiFiToyPreset * _Nonnull p, NSString * _Nullable error))resultHandler;

@end
