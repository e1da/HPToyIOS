//
//  HiFiToyPresetTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 14/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HiFiToyPreset.h"
#import "PeripheralData.h"

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

- (void) testCopy {
    XCTAssertTrue(p0 != p1);
    
    XCTAssertTrue(p0.filters != p1.filters);
    for (int i = 0 ; i < 7 ; i++) {
        XCTAssertTrue([p0.filters getBiquadAtIndex:i] != [p1.filters getBiquadAtIndex:i]);
        XCTAssertTrue([[p0.filters getBiquadAtIndex:i] biquadParam] != [[p1.filters getBiquadAtIndex:i] biquadParam]);
    }
    
    XCTAssertTrue(p0.masterVolume != p1.masterVolume);
    
    XCTAssertTrue(p0.bassTreble                 != p1.bassTreble);
    XCTAssertTrue(p0.bassTreble.bassTreble127   != p1.bassTreble.bassTreble127);
    XCTAssertTrue(p0.bassTreble.bassTreble34    != p1.bassTreble.bassTreble34);
    XCTAssertTrue(p0.bassTreble.bassTreble56    != p1.bassTreble.bassTreble56);
    XCTAssertTrue(p0.bassTreble.bassTreble8     != p1.bassTreble.bassTreble8);
    
    XCTAssertTrue(p0.loudness           != p1.loudness);
    XCTAssertTrue(p0.loudness.biquad    != p1.loudness.biquad);
    
    XCTAssertTrue(p0.drc                != p1.drc);
    XCTAssertTrue(p0.drc.coef17         != p1.drc.coef17);
    XCTAssertTrue(p0.drc.coef8          != p1.drc.coef8);
    XCTAssertTrue(p0.drc.timeConst17    != p1.drc.timeConst17);
    XCTAssertTrue(p0.drc.timeConst8     != p1.drc.timeConst8);
}

- (void) testEqualAndCopy {
    p0.masterVolume.db = -0.3f;
    XCTAssertNotEqualObjects(p0, p1);
    
    Biquad * b = [p0.filters getBiquadAtIndex:2];
    b.biquadParam.freq = 2500;
    b.biquadParam.dbVolume = 12;
    
    p1 = [p0 copy];
    XCTAssertEqualObjects(p0, p1);
    
}

- (void) testGetDataBufs {
    Biquad * b = [p0.filters getBiquadAtIndex:2];
    b.biquadParam.freq = 2500;
    b.biquadParam.dbVolume = 12;
    
    PeripheralData * pd = [[PeripheralData alloc] initWithPreset:p0];
    [p1 importFromDataBufs:pd.dataBufs];
    
    Biquad * b1 = [p0.filters getBiquadAtIndex:2];
    Biquad * b2 = [p1.filters getBiquadAtIndex:2];
    
    XCTAssertEqualObjects(b1, b2);
    XCTAssertEqualObjects(p0.filters, p1.filters);
    XCTAssertEqualObjects(p0.masterVolume, p1.masterVolume);
    XCTAssertEqualObjects(p0.bassTreble, p1.bassTreble);
    XCTAssertEqualObjects(p0.loudness, p1.loudness);
    XCTAssertEqualObjects(p0.drc, p1.drc);
    
    [p0.filters upOrderFor:BIQUAD_LOWPASS];
    
    pd = [[PeripheralData alloc] initWithPreset:p0];
    [p1 importFromDataBufs:pd.dataBufs];
    //XCTAssertEqualObjects(p0, p1);
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
