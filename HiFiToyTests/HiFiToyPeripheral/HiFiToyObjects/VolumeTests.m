//
//  VolumeTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Volume.h"
#import "FloatUtility.h"

@interface VolumeTests : XCTestCase {
    Volume * v0;
    Volume * v1;
}

@end

@implementation VolumeTests

- (void)setUp {
    v0 = [Volume initWithAddress:0 dbValue:0.0 maxDb:0.0 minDb:MUTE_VOLUME];
    v1 = [v0 copy];
    
}

- (void) testCopy {
    v1.db = -0.05f;
    XCTAssertTrue(isFloatNull(v1.db - v1.db));
    XCTAssertFalse(isFloatNull(v0.db - v1.db));
}

- (void) testEqual {
    v1.db = -0.05f;
    XCTAssertNotEqualObjects(v0, v1);
    
    v1.db = 0;
    XCTAssertEqualObjects(v0, v1);
    
}

- (void) testGetBinary {
    NSData * d = [v0 getBinary];
    XCTAssertTrue(d.length == 6);
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    [v0 setDbPercent:0.05];
    
    NSData * xmlData = [[v0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:v1];
    
    XCTAssertEqualObjects(v0, v1);
    
}


@end
