//
//  FloatUtilityTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FloatUtility.h"

@interface FloatUtilityTests : XCTestCase

@end

@implementation FloatUtilityTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

@end
