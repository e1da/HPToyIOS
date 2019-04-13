//
//  BiquadTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Biquad.h"

@interface BiquadTests : XCTestCase {
    Biquad * b0;
    Biquad * b1;
}

@end

@implementation BiquadTests

- (void)setUp {
    b0 = [Biquad initWithAddress0:0x51 Address1:0x52];
    b0.type = BIQUAD_PARAMETRIC;
    b1 = [b0 copy];
    
}

- (void) testCopy {
    XCTAssertTrue(b0.biquadParam.delegate == b0);
    XCTAssertTrue(b1.biquadParam.delegate == b1);
    
    b1.enabled = NO;
    XCTAssertTrue(b0.enabled != b1.enabled);
    
    b1.biquadParam.freq = 150;
    XCTAssertTrue(b0.biquadParam.freq != b1.biquadParam.freq);
}

- (void) testEqual {
    b1.biquadParam.freq = 150;
    XCTAssertNotEqualObjects(b0, b1);
    
    b1.biquadParam.freq = 100;
    XCTAssertEqualObjects(b0, b1);
}

- (void) testGetBinary {
    NSData * d = [b0 getBinary];
    XCTAssertTrue(d.length == 44);
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    b0.biquadParam.freq = 1000;
    XCTAssertNotEqualObjects(b0, b1);
    
    NSData * xmlData = [[b0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:b1];
    
    XCTAssertEqualObjects(b0, b1);
    
}


@end
