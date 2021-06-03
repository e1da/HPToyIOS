//
//  AmMode.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 20/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface AmMode : NSObject <HiFiToyObject>

@property (readonly, getter=isSuccessImport) BOOL successImport;

/* -------------------- init state methods -------------------- */
- (void) reset;

/* ------------------ setter getter methods ------------------ */
- (uint8_t) getData:(int)index;
- (void) setData:(uint8_t)d toIndex:(int)index;

- (BOOL) isEnabled;
- (void) setEnabled:(BOOL)enabled;

/* ------------------- export import methods ------------------- */
- (void) storeToPeripheral;
- (void) importFromPeripheral:(void (^ __nullable)(void))finishHandler;

@end

NS_ASSUME_NONNULL_END
