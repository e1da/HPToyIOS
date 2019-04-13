//
//  DrcCoefTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DrcCoef.h"

@interface DrcCoefTests : XCTestCase {
    DrcCoef * dc0;
    DrcCoef * dc1;
}

@end

@implementation DrcCoefTests

- (void)setUp {
    dc0 = [DrcCoef initWithChannel:DRC_CH_1_7
                            Point0:initDrcPoint(POINT0_INPUT_DB, -120)
                            Point1:initDrcPoint(-72, -72)
                            Point2:initDrcPoint(-24, -24)
                            Point3:initDrcPoint(POINT3_INPUT_DB, -24)];
    dc1 = [dc0 copy];
}

- (void) testEqual {
    [dc0 setPoint0WithCheck:initDrcPoint(POINT0_INPUT_DB, -60.0f)];
    XCTAssertNotEqualObjects(dc0, dc1);
    
    [dc0 setPoint0WithCheck:initDrcPoint(POINT0_INPUT_DB, -120.0f)];
    XCTAssertEqualObjects(dc0, dc1);
    
}

- (void) testGetBinary {
    NSData * d = [dc0 getBinary];
    XCTAssertTrue(d.length == 30);
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    [dc0 setPoint0WithCheck:initDrcPoint(POINT0_INPUT_DB, -60.0f)];
    
    NSData * xmlData = [[dc0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:dc1];
    
    XCTAssertEqualObjects(dc0, dc1);
    
}


@end
