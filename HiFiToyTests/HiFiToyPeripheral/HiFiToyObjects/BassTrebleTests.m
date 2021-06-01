//
//  BassTrebleTests.m
//  HiFiToyTests
//
//  Created by Kerosinn_OSX on 12/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BassTreble.h"


@interface BassTrebleTests : XCTestCase {
    BassTreble * bt0;
    BassTreble * bt1;

}

@end

@implementation BassTrebleTests

- (void)setUp {
    BassTrebleChannel * bassTreble12 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_127
                                                                 BassFreq:BASS_FREQ_125 BassDb:0
                                                               TrebleFreq:TREBLE_FREQ_9000 TrebleDb:0
                                                                maxBassDb:12 minBassDb:-12
                                                              maxTrebleDb:12 minTrebleDb:-12];
    bt0 = [BassTreble initWithBassTreble127:bassTreble12];
    bt1 = [bt0 copy];
    
}

- (void) testCopy {
    bt1.bassTreble127.bassDb = 1;
    XCTAssertTrue(bt0.bassTreble127.bassDb != bt1.bassTreble127.bassDb);
    
    bt1.bassTreble127.bassDb = 0;
    XCTAssertTrue(bt0.bassTreble127.bassDb == bt1.bassTreble127.bassDb);
                  
    [bt1 setEnabledChannel:0 Enabled:0.5];
    XCTAssertTrue([bt0 getEnabledChannel:0] != [bt1 getEnabledChannel:0]);
}

- (void) testEqual {
    bt1.bassTreble127.bassDb = 1;
    XCTAssertNotEqualObjects(bt0, bt1);
    
    bt1.bassTreble127.bassDb = 0;
    XCTAssertEqualObjects(bt0, bt1);
    
    [bt1 setEnabledChannel:0 Enabled:0.5];
    XCTAssertNotEqualObjects(bt0, bt1);
    
}

- (void) testGetDataBufs {
    NSArray<HiFiToyDataBuf *> * db = [bt0 getDataBufs];
    XCTAssertTrue(db.count == 9);
}

/*- (void) testImport {
    bt0.bassTreble127.bassDb = 1;
    NSData * d = [bt0 getBinary];
    
    if (![bt1 importData:d]) {
        XCTFail(@"Import is not success.");
    }
    
    XCTAssertEqualObjects(bt0, bt1);
    
    [bt0 setEnabledChannel:0 Enabled:0.5];
    d = [bt0 getBinary];
    
    if (![bt1 importData:d]) {
        XCTFail(@"Import is not success.");
    }
    
    XCTAssertEqualObjects(bt0, bt1);
}*/

- (void) testXmlExportImport {
    bt0.bassTreble127.bassDb = 1;
    [bt0 setEnabledChannel:0 Enabled:0.5];
    
    NSData * xmlData = [[bt0 toXmlData] toNSData];
    XmlParserWrapper * parser = [[XmlParserWrapper alloc] init];
    [parser startParsingWithData:xmlData withDelegate:bt1];
    
    XCTAssertEqualObjects(bt0, bt1);
    
}


@end
