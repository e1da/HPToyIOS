//
//  BiquadTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Biquad.h"
#import "FloatUtility.h"

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

- (void) testParamToCoef {
    b0.type = BIQUAD_PARAMETRIC;
    b0.biquadParam.freq = 45;
    b0.biquadParam.qFac = 1.41f;
    b0.biquadParam.dbVolume = -3.0f;
    
    XCTAssertTrue(isCoefEqual(b0.coef.b0, 0.999637926f));
    XCTAssertTrue(isCoefEqual(b0.coef.b1, -1.997511844f));
    XCTAssertTrue(isCoefEqual(b0.coef.b2, 0.997882581f));
    XCTAssertTrue(isCoefEqual(b0.coef.a1, 1.997511844f));
    XCTAssertTrue(isCoefEqual(b0.coef.a2, -0.997520508f));
    
    BiquadCoef_t coefParam = {0.999637926f, -1.997511844f, 0.997882581f, 1.997511844f, -0.997520508f};
    b0.coef = coefParam;
    
    XCTAssertEqual(b0.type, BIQUAD_PARAMETRIC);
    XCTAssertEqual(b0.biquadParam.freq, 45);
    XCTAssertTrue(isFloatDiffLessThan(b0.biquadParam.qFac, 1.41f, 0.01f));
    XCTAssertTrue(isFloatDiffLessThan(b0.biquadParam.dbVolume, -3.0f, 0.01f));
}

- (void) testCopy {
    XCTAssertTrue(b0.biquadParam.delegate == b0);
    XCTAssertTrue(b1.biquadParam.delegate == b1);
    
    b1.enabled = NO;
    XCTAssertTrue(b0.enabled != b1.enabled);
    
    b1.biquadParam.freq = 150;
    XCTAssertTrue(b0.biquadParam.freq != b1.biquadParam.freq);
}

- (void) testEqualAndCopy {
    b0.biquadParam.freq = 2500;
    b0.biquadParam.dbVolume = 12;
    
    XCTAssertNotEqualObjects(b0, b1);
    
    b1 = [b0 copy];
    XCTAssertEqualObjects(b0, b1);
}

- (void) testGetDataBufs {
    b0.biquadParam.freq = 2500;
    b0.biquadParam.dbVolume = 12;

    NSArray<HiFiToyDataBuf *> * db = [b0 getDataBufs];
    XCTAssertTrue(db.count == 2);
    
    XCTAssertTrue(db[0].length == 20);
    XCTAssertTrue(db[1].length == 20);
    
    [b1 importFromDataBufs:db];
    XCTAssertEqualObjects(b0, b1);
    
    
}

- (void) testXmlExportImport {
    b0.biquadParam.freq = 1000;
    XCTAssertNotEqualObjects(b0, b1);
    
    NSData * xmlData = [[b0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:b1];
    
    XCTAssertEqualObjects(b0, b1);
    
}

- (void) testSerialization {
    b0.type = BIQUAD_PARAMETRIC;
    b0.biquadParam.freq = 60;
    b0.biquadParam.qFac = 2.35f;
    b0.biquadParam.dbVolume = 3.0f;
    
    //check archive: encoder, decoder
    NSData * d = [NSKeyedArchiver archivedDataWithRootObject:b0];
    b1 = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    
    XCTAssertEqualObjects(b0, b1);
}

@end
