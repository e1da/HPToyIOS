//
//  DrcTimeConstTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 13/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DrcTimeConst.h"

@interface DrcTimeConstTests : XCTestCase {
    DrcTimeConst * dt0;
    DrcTimeConst * dt1;
}

@end

@implementation DrcTimeConstTests

- (void)setUp {
    dt0 = [DrcTimeConst initWithChannel:DRC_CH_1_7 Energy:0.1f Attack:10.0f Decay:100.0f];
    dt1 = [dt0 copy];
}

- (void) testEqual {
    dt0.energyMS = 1.5f;
    XCTAssertNotEqualObjects(dt0, dt1);
    
    dt0.energyMS = 0.1f;
    XCTAssertEqualObjects(dt0, dt1);
    
}

- (void) testGetBinary {
    NSData * d = [dt0 getBinary];
    XCTAssertTrue(d.length == 28);
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    dt0.energyMS = 1.5f;
    
    NSData * xmlData = [[dt0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:dt1];
    
    XCTAssertEqualObjects(dt0, dt1);
    
}

@end
