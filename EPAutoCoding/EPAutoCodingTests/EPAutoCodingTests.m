//
//  EPAutoCodingTests.m
//  EPAutoCodingTests
//
//  Created by Michel Bouwmans on 26/11/13.
//  Copyright (c) 2013 Michel Bouwmans. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "EPAutoCoding.h"

@interface TestCaseClass : EPAutoCoding

@property (nonatomic) NSString* string;
@property (nonatomic) NSNumber* number;

@end

@implementation TestCaseClass
@end

@interface EPAutoCodingTests : XCTestCase {
    TestCaseClass* testObject;
    TestCaseClass* unarchivedObject;
    NSURL* archiveURL;
}
@end

@implementation EPAutoCodingTests

- (void)setUp {
    [super setUp];

    testObject = [[TestCaseClass alloc] init];
    testObject.string = @"testString";
    testObject.number = @16000;

    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:testObject];

    if (!archiveURL) archiveURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"archive.plist"];
    [data writeToURL:archiveURL atomically:YES];

    unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:archiveURL.relativePath];
}

- (void)tearDown {
    [super tearDown];

    unarchivedObject = testObject = nil;

    NSError* error;
    [[NSFileManager defaultManager] removeItemAtURL:archiveURL error:&error];
    XCTAssertNil(error, @"Error during removal of test archive.");
}

- (void)testNSNumberCoding {
    XCTAssertEqualObjects(testObject.number, unarchivedObject.number, @"Unarchived object has different NSNumber");
}

- (void)testNSStringCoding {
    XCTAssertEqualObjects(testObject.string, unarchivedObject.string, @"Unarchived object has different NSString");
}

@end
