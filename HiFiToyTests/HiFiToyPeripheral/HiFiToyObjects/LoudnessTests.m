//
//  LoudnessTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Loudness.h"
#import "FloatUtility.h"

@interface LoudnessTests : XCTestCase {
    Loudness * l0;
    Loudness * l1;
}

@end

@implementation LoudnessTests

- (void)setUp {
    //Loudness: LG = -0.5, LO = Gain = Offset = 0, Biquad=(BANDPASS, 140Hz = (30..200Hz))
    l0 = [[Loudness alloc] init];
    l1 = [l0 copy];
    
}

- (void) testCopy {
    XCTAssertTrue(l0.biquad != l1.biquad);
    XCTAssertTrue(l0.biquad.biquadParam != l1.biquad.biquadParam);
    
    l1.gain = 0.0001f;
    XCTAssertFalse(isFloatNull(l0.gain - l1.gain));
    
    l1.gain = 0.0f;
    XCTAssertTrue(isFloatNull(l0.gain - l1.gain));
    
    l1.biquad.biquadParam.freq = 70;
    XCTAssertTrue(l0.biquad.biquadParam.freq != l1.biquad.biquadParam.freq);
}

- (void) testEqual {
    l1.gain = 0.05f;
    XCTAssertNotEqualObjects(l0, l1);
    
    l1.gain = 0.0f;
    XCTAssertEqualObjects(l0, l1);
    
    l1.biquad.biquadParam.freq = 70;
    XCTAssertNotEqualObjects(l0, l1);
    
}

- (void) testGetBinary {
    NSData * d = [l0 getBinary];
    XCTAssertTrue(d.length == (22 + 18));
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    l0.gain = 0.05f;
    XCTAssertNotEqualObjects(l0, l1);
    
    NSData * xmlData = [[l0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:l1];
    
    XCTAssertEqualObjects(l0, l1);
    
}

@end
