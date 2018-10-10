//
//  HiFiToyTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FloatUtility.h"
#import "BiquadLL.h"

@interface HiFiToyTests : XCTestCase

@end

@implementation HiFiToyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testFloatEqualNull {
    float a = 1.000456f;
    XCTAssertFalse(isFloatNull(a));
    
    a = -1.000456f;
    XCTAssertFalse(isFloatNull(a));
    
    a = 0.000456f;
    XCTAssertFalse(isFloatNull(a));
    
    a = -0.000456f;
    XCTAssertFalse(isFloatNull(a));
    
    a = 37.000456f;
    XCTAssertFalse(isFloatNull(a));
    
    a = -10256.000456f;
    XCTAssertFalse(isFloatNull(a));
    
    a = 0.0f;
    XCTAssertTrue(isFloatNull(a));
    
    a = 0.0000000000000000000000000000000000000000001f;
    XCTAssertFalse(isFloatNull(a));
    
    a = -0.0000000000000000000000000000000000000000001f;
    XCTAssertFalse(isFloatNull(a));
    
    a = NAN;
    XCTAssertFalse(isFloatNull(a));
    
    a = 1.0f / 0.0f;
    XCTAssertFalse(isFloatNull(a));
    
}

- (void) testFloatEqual {
    XCTAssertTrue(isCoefEqual(0.9999994f, 0.9999995f));
    XCTAssertTrue(isCoefEqual(-0.9999994f, -0.9999995f)); //over for float
    
    XCTAssertFalse(isCoefEqual(1.99994f, 1.99995f));
    XCTAssertFalse(isCoefEqual(-1.99994f, -1.99995f));
    XCTAssertFalse(isCoefEqual(-1.99994f, 1.99995f));
    
    XCTAssertFalse(isCoefEqual(NAN, 1.999999995f));
    XCTAssertFalse(isCoefEqual(1.0f / 0.0f, 0.0f));
    XCTAssertTrue(isCoefEqual(1.999994f, 1.999994f));
    XCTAssertTrue(isCoefEqual(-1.999994f, -1.999994f));
    XCTAssertFalse(isCoefEqual(-1.999994f, 1.999994f));
    
    XCTAssertTrue(isCoefEqual(-1.94f, -1.94f));
    XCTAssertFalse(isCoefEqual(-1.94f, 1.94f));
    
}
- (void) testBiquadLLCoefAndParams {
    BiquadLL * biquad = [BiquadLL initWithAddress:0x51];
    
    BiquadParam_t biquadParam;
    biquadParam.order = BIQUAD_ORDER_2;
    biquadParam.type = BIQUAD_PARAMETRIC;
    biquadParam.freq = 100;
    biquadParam.qFac = 1.41f;
    biquadParam.dbVolume = 3.0f;
    
    [biquad setBiquadParam:biquadParam];
    biquadParam = [biquad getBiquadParam];
    
    XCTAssertEqual(biquadParam.order, BIQUAD_ORDER_2);
    XCTAssertEqual(biquadParam.type, BIQUAD_PARAMETRIC);
    XCTAssertEqual(biquadParam.freq, 100, @"Freq error");
    XCTAssertTrue(isFloatDiffLessThan(biquadParam.qFac, 1.41f, 0.01f));
    XCTAssertTrue(isFloatDiffLessThan(biquadParam.dbVolume, 3.0f, 0.01f));
    
    XCTAssertFalse(isFloatDiffLessThan(biquadParam.dbVolume, 3.015f, 0.01f));
    
    biquadParam.type = BIQUAD_LOWPASS;
    [biquad setBiquadParam:biquadParam];
    
    biquadParam = [biquad getBiquadParam];
    XCTAssertEqual(biquadParam.order, BIQUAD_ORDER_2);
    XCTAssertEqual(biquadParam.type, BIQUAD_LOWPASS);
    XCTAssertEqual(biquadParam.freq, 100, @"Freq error");
    
    biquadParam.type = BIQUAD_HIGHPASS;
    [biquad setBiquadParam:biquadParam];
    
    biquadParam = [biquad getBiquadParam];
    XCTAssertEqual(biquadParam.order, BIQUAD_ORDER_2);
    XCTAssertEqual(biquadParam.type, BIQUAD_HIGHPASS);
    XCTAssertEqual(biquadParam.freq, 100, @"Freq error");
    
    biquadParam.type = BIQUAD_ALLPASS;
    biquadParam.freq = 350;
    [biquad setBiquadParam:biquadParam];
    
    biquadParam = [biquad getBiquadParam];
    XCTAssertEqual(biquadParam.order, BIQUAD_ORDER_2);
    XCTAssertEqual(biquadParam.type, BIQUAD_ALLPASS);
    XCTAssertEqual(biquadParam.freq, 350, @"Freq error");
    
    BiquadCoef_t coef = {0.5f, -0.5f, 1.994f, -0.98f, -1.5f};
    biquad.coef = coef;
    
    biquadParam = [biquad getBiquadParam];
    XCTAssertEqual(biquadParam.order, BIQUAD_ORDER_2);
    XCTAssertEqual(biquadParam.type, BIQUAD_USER);
    
    biquadParam.order = BIQUAD_ORDER_2;
    biquadParam.type = BIQUAD_PARAMETRIC;
    biquadParam.freq = 45;
    biquadParam.qFac = 1.41f;
    biquadParam.dbVolume = -3.0f;
    [biquad setBiquadParam:biquadParam];

    XCTAssertTrue(isCoefEqual(biquad.coef.b0, 0.999637926f));
    XCTAssertTrue(isCoefEqual(biquad.coef.b1, -1.997511844f));
    XCTAssertTrue(isCoefEqual(biquad.coef.b2, 0.997882581f));
    XCTAssertTrue(isCoefEqual(biquad.coef.a1, 1.997511844f));
    XCTAssertTrue(isCoefEqual(biquad.coef.a2, -0.997520508f));
    
    BiquadCoef_t coefParam = {0.999637926f, -1.997511844f, 0.997882581f, 1.997511844f, -0.997520508f};
    biquad.coef = coefParam;
    
    biquadParam = [biquad getBiquadParam];
    XCTAssertEqual(biquadParam.order, BIQUAD_ORDER_2);
    XCTAssertEqual(biquadParam.type, BIQUAD_PARAMETRIC);
    XCTAssertEqual(biquadParam.freq, 45);
    XCTAssertTrue(isFloatDiffLessThan(biquadParam.qFac, 1.41f, 0.01f));
    XCTAssertTrue(isFloatDiffLessThan(biquadParam.dbVolume, -3.0f, 0.01f));
}

- (void) testBiquadLLEqualsCopyArchive {
    BiquadLL * biquad = [BiquadLL initWithAddress:0x51];
    
    BiquadParam_t biquadParam;
    biquadParam.order = BIQUAD_ORDER_2;
    biquadParam.type = BIQUAD_PARAMETRIC;
    biquadParam.freq = 100;
    biquadParam.qFac = 1.41f;
    biquadParam.dbVolume = 3.0f;
    
    [biquad setBiquadParam:biquadParam];
    
    BiquadLL * biquad1 = [BiquadLL initWithAddress:0x51];
    
    biquadParam.order = BIQUAD_ORDER_2;
    biquadParam.type = BIQUAD_PARAMETRIC;
    biquadParam.freq = 100;
    biquadParam.qFac = 1.41f;
    biquadParam.dbVolume = 3.0f;
    
    [biquad1 setBiquadParam:biquadParam];
    
    XCTAssertTrue([biquad1 isEqual:biquad]);
    
    biquadParam.type = BIQUAD_LOWPASS;
    [biquad1 setBiquadParam:biquadParam];
    XCTAssertFalse([biquad1 isEqual:biquad]);
    
    biquadParam.type = BIQUAD_PARAMETRIC;
    [biquad1 setBiquadParam:biquadParam];
    XCTAssertTrue([biquad1 isEqual:biquad]);
    
    biquadParam.qFac = 1.45f;
    [biquad1 setBiquadParam:biquadParam];
    XCTAssertFalse([biquad1 isEqual:biquad]);
    
    biquadParam.qFac = 1.41f;
    [biquad1 setBiquadParam:biquadParam];
    [biquad setType:BIQUAD_LOWPASS];
    [biquad1 setType:BIQUAD_LOWPASS];
    XCTAssertTrue([biquad1 isEqual:biquad]);
    
    //check copy
    BiquadLL * biquad2 = [biquad1 copy];
    XCTAssertTrue([biquad2 isEqual:biquad1]);
    
    //check archive: encoder, decoder
    NSData * d = [NSKeyedArchiver archivedDataWithRootObject:biquad2];
    BiquadLL * biquad3 = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    XCTAssertTrue([biquad3 isEqual:biquad2]);
    
    [biquad3 setFreq:500];
    XCTAssertFalse([biquad3 isEqual:biquad2]);
}

@end
