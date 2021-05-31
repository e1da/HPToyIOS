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

#define FIRST_DATA_BUF_OFFSET 0x24

@interface AmMode : NSObject


@property (readonly, getter=isSuccessImport) BOOL successImport;

- (void) reset;
- (uint8_t) getData:(int)index;
- (void) setData:(uint8_t)d toIndex:(int)index;

- (BOOL) isEnabled;
- (void) setEnabled:(BOOL)enabled;

- (void) storeToPeripheral;
- (void) importFromPeripheral;

@end

NS_ASSUME_NONNULL_END
