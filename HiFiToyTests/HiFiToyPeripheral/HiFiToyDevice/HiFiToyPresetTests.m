//
//  HiFiToyPresetTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 14/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HiFiToyPreset.h"

@interface HiFiToyPresetTests : XCTestCase {
    HiFiToyPreset * p0;
    HiFiToyPreset * p1;
}

@end

@implementation HiFiToyPresetTests

- (void)setUp {
    p0 = [HiFiToyPreset getDefault];
    p1 = [p0 copy];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) testCharacteristicPointer:(HiFiToyPreset *)p {
    XCTAssertTrue(p.characteristics.count == 5);
    
    XCTAssertTrue([p.characteristics objectAtIndex:0] == p.filters);
    XCTAssertTrue([p.characteristics objectAtIndex:1] == p.masterVolume);
    XCTAssertTrue([p.characteristics objectAtIndex:2] == p.bassTreble);
    XCTAssertTrue([p.characteristics objectAtIndex:3] == p.loudness);
    XCTAssertTrue([p.characteristics objectAtIndex:4] == p.drc);
}

- (void) testCopy {
    XCTAssertTrue(p0 != p1);
    [self testCharacteristicPointer:p0];
    [self testCharacteristicPointer:p1];
    
    for (int i = 0; i < p0.characteristics.count; i++) {
        XCTAssertTrue([p0.characteristics objectAtIndex:i] != [p1.characteristics objectAtIndex:i]);
    }
}

- (void) testEqual {
    p0.masterVolume.db = -0.3f;
    XCTAssertNotEqualObjects(p0, p1);
    
    p0.masterVolume.db = 0.0f;
    XCTAssertEqualObjects(p0, p1);
    
}

- (void) testGetDataBufs {
    NSArray<HiFiToyDataBuf *> * db = [p0 getDataBufs];
    //XCTAssertTrue(d.length == (308 + 6 + 98 + 40 + 206));
}

/*- (void) testImport {
 
 }*/

- (void) testXmlExportImport {
    p0.masterVolume.db = -0.3f;
    
    NSData * xmlData = [[p0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:p1];
    
    XCTAssertEqualObjects(p0, p1);
    
}


@end
