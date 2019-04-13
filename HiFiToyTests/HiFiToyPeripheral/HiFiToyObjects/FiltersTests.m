//
//  FiltersTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Filters.h"
#import "TAS5558.h"

@interface FiltersTests : XCTestCase {
    Filters * f0;
    Filters * f1;
}

@end

@implementation FiltersTests

- (void)setUp {
    f0 = [Filters initDefaultWithAddr0:BIQUAD_FILTER_REG withAddr1:(BIQUAD_FILTER_REG + 7)];
    f1 = [f0 copy];
}

- (void) testCopy {
    XCTAssertTrue(f0 != f1);
    
    for (int i = 0; i < 7; i++) {
        XCTAssertTrue([f0 getBiquadAtIndex:i] != [f1 getBiquadAtIndex:i]);
    }
}

- (void) testEqual {
    Biquad * b = [f0 getBiquadAtIndex:0];
    b.biquadParam.freq = 150;

    XCTAssertNotEqualObjects(f0, f1);
    
    b.biquadParam.freq = 100;
    XCTAssertEqualObjects(f0, f1);
    
}

- (void) testGetBinary {
    NSData * d = [f0 getBinary];
    XCTAssertTrue(d.length == (44 * 7));
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    Biquad * b = [f0 getBiquadAtIndex:0];
    b.biquadParam.freq = 150;
    
    NSData * xmlData = [[f0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:f1];
    
    XCTAssertEqualObjects(f0, f1);
    
}


@end
