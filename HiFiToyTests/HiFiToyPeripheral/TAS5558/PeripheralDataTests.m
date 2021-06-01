//
//  PeripheralDataTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 01/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PeripheralData.h"

@interface PeripheralDataTests : XCTestCase

@end

@implementation PeripheralData(GET)

- (PeripheralHeader_t *) getHeader {
    return &header;
}

@end

@implementation PeripheralDataTests {
    PeripheralData * pd;
}

- (void)setUp {
    pd = [[PeripheralData alloc] init];
}

- (void)testSize {
    PeripheralHeader_t * h = [pd getHeader];
    XCTAssertTrue(sizeof(*h) == 0x26, "Peripheral header size is not correct!");
}


@end
