//
//  SASLMechanism.h
//  SASLKit
//
//  Created by Tobias Kraentzer on 17.05.16.
//  Copyright © 2016 Tobias Kräntzer.
//
//  This file is part of SASLKit.
//
//  SASLKit is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  SASLKit is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  SASLKit. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
//


#import <Foundation/Foundation.h>

extern NSString *const SASLMechanismErrorDomain;

typedef NS_ENUM(NSInteger, SASLMechanismErrorCode) {
    SASLMechanismErrorCodeNoCredentials
};

@class SASLMechanism;

@protocol SASLMechanismDelegate <NSObject>
@optional
- (void)SASLMechanismNeedsCredentials:(SASLMechanism *)mechanism;
@end

@interface SASLMechanism : NSObject

#pragma mark Registered Mechanisms
+ (NSDictionary *)registeredMechanisms;
+ (void)registerMechanismClass:(Class)mechanismClass forMechanismName:(NSString *)mechanismName;

#pragma mark Mechanism Name
+ (NSString *)name;

#pragma mark Delegate
@property (nonatomic, weak) id<SASLMechanismDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

#pragma mark Context
@property (nonatomic, strong) id context;

#pragma mark Authentication Exchange
- (void)beginAuthenticationExchangeWithHostname:(NSString *)hostname
                                responseHandler:(void (^)(NSData *initialResponse, BOOL abort))responseHandler;
- (void)handleChallenge:(NSData *)challenge
        responseHandler:(void (^)(NSData *response, BOOL abort))responseHandler;

#pragma mark Authentication Outcome
- (void)succeedWithData:(NSData *)data;
- (void)failedWithError:(NSError *)error;

@end
