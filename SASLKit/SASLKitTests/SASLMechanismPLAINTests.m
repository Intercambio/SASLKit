//
//  SASLMechanismPLAINTests.m
//  SASLKit
//
//  Created by Tobias Kraentzer on 17.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SASLKit/SASLKit.h>

@interface SASLMechanismPLAINTests : XCTestCase <SASLMechanismDelegate>
@property (nonatomic, assign) BOOL abortAuthentication;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) XCTestExpectation *completionExpectation;
@property (nonatomic, assign) BOOL completionSuccess;
@property (nonatomic, strong) NSError *completionError;
@end

@implementation SASLMechanismPLAINTests

- (void)setUp
{
    [super setUp];
    
    self.abortAuthentication = NO;
    self.username = nil;
    self.password = nil;
}

- (void)testWithCredentials
{
    self.username = @"romeo";
    self.password = @"123";
    
    SASLMechanismPLAIN *mechanism = [[SASLMechanismPLAIN alloc] init];
    mechanism.delegate = self;
    
    XCTestExpectation *expectResponse = [self expectationWithDescription:@"Expecting inital response"];
    self.completionExpectation = [self expectationWithDescription:@"Authentication Completion"];
    
    [mechanism beginAuthenticationExchangeWithHostname:@"localhost"
                                       responseHandler:^(NSData *initialResponse, BOOL abort) {
                                           
                                           XCTAssertFalse(abort);
                                           
                                           unsigned short nul[] = {0};
                                           NSData *terminator = [NSData dataWithBytes:nul length:1];
                                           
                                           NSString *initialResponseString = [[NSString alloc] initWithData:initialResponse encoding:NSUTF8StringEncoding];
                                           NSString *terminatorString = [[NSString alloc] initWithData:terminator encoding:NSUTF8StringEncoding];
                                           
                                           NSArray *components = [initialResponseString componentsSeparatedByString:terminatorString];
                                           
                                           NSArray *expectedComponents = @[@"", @"romeo", @"123"];
                                           XCTAssertEqualObjects(components, expectedComponents);
                                           
                                           [mechanism succeedWithData:nil];
                                           
                                           [expectResponse fulfill];
                                       }];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(self.completionSuccess);
    XCTAssertNil(self.completionError);
}

- (void)testMissingCredentials
{
    self.username = @"romeo";
    
    SASLMechanismPLAIN *mechanism = [[SASLMechanismPLAIN alloc] init];
    mechanism.delegate = self;
    
    XCTestExpectation *expectResponse = [self expectationWithDescription:@"Expecting inital response"];
    self.completionExpectation = [self expectationWithDescription:@"Authentication Completion"];
    
    [mechanism beginAuthenticationExchangeWithHostname:@"localhost"
                                       responseHandler:^(NSData *initialResponse, BOOL abort) {
                                           XCTAssertTrue(abort);
                                           
                                           [expectResponse fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertFalse(self.completionSuccess);
    XCTAssertEqualObjects(self.completionError.domain, SASLMechanismErrorDomain);
    XCTAssertEqual(self.completionError.code, SASLMechanismErrorCodeNoCredentials);
}

- (void)testAbort
{
    self.abortAuthentication = YES;
    
    SASLMechanismPLAIN *mechanism = [[SASLMechanismPLAIN alloc] init];
    mechanism.delegate = self;
    
    XCTestExpectation *expectResponse = [self expectationWithDescription:@"Expecting inital response"];
    
    [mechanism beginAuthenticationExchangeWithHostname:@"localhost"
                                       responseHandler:^(NSData *initialResponse, BOOL abort) {
                                           XCTAssertTrue(abort);
                                           
                                           [expectResponse fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

#pragma mark SASLMechanismDelegatePLAIN

- (void)SASLMechanismNeedsCredentials:(SASLMechanism *)mechanism
{
    if ([mechanism isKindOfClass:[SASLMechanismPLAIN class]]) {
        SASLMechanismPLAIN *plainMechanism = (SASLMechanismPLAIN *)mechanism;
        if (self.abortAuthentication) {
            [plainMechanism abort];
        } else {
            [plainMechanism authenticateWithUsername:self.username
                                            password:self.password
                                          completion:^(BOOL success, NSError *error) {
                                              self.completionSuccess = success;
                                              self.completionError = error;
                                              [self.completionExpectation fulfill];
                                          }];
        }
    }
}

@end
