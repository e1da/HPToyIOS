//
//  XOver.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 27/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamFilterContainer.h"
#import "PassFilter.h"

@interface XOver : NSObject <NSCoding, NSCopying>

@property (nonatomic) int               address;

@property (nonatomic) ParamFilterContainer   * params;
@property (nonatomic) PassFilter        * hp;
@property (nonatomic) PassFilter        * lp;

- (void) update;

@end
