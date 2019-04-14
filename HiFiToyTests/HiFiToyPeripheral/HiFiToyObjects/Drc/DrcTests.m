//
//  DrcTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 14/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Drc.h"

@interface DrcTests : XCTestCase {
    Drc * drc0;
    Drc * drc1;
}

@end

@implementation DrcTests

- (void)setUp {
    drc0 = [[Drc alloc] init];
    drc1 = [drc0 copy];
}

- (void) testCopy {
    XCTAssertTrue(drc0 != drc1);
    
    XCTAssertTrue(drc0.coef17 != drc1.coef17);
    XCTAssertTrue(drc0.coef8 != drc1.coef8);
    XCTAssertTrue(drc0.timeConst17 != drc1.timeConst17);
    XCTAssertTrue(drc0.timeConst8 != drc1.timeConst8);
}

- (void) testEqual {
    [drc0 setEnabled:1.0f forChannel:0];
    XCTAssertNotEqualObjects(drc0, drc1);
    
    [drc0 setEnabled:0.0f forChannel:0];
    XCTAssertEqualObjects(drc0, drc1);
    
}

- (void) testGetBinary {
    NSData * d = [drc0 getBinary];
    XCTAssertTrue(d.length == 206);
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    [drc0 setEnabled:1.0f forChannel:0];
    
    NSData * xmlData = [[drc0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:drc1];
    
    XCTAssertEqualObjects(drc0, drc1);
    
}

@end
