//
//  SASLMechanism.m
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


#import "SASLMechanism.h"

NSString *const SASLMechanismErrorDomain = @"SASLMechanismErrorDomain";

@implementation SASLMechanism

#pragma mark Registered Mechanisms

+ (NSMutableDictionary *)sasl_registeredMechanisms
{
    static NSMutableDictionary *registeredMechanisms;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredMechanisms = [[NSMutableDictionary alloc] init];
    });
    return registeredMechanisms;
}

+ (NSDictionary *)registeredMechanisms
{
    return [self sasl_registeredMechanisms];
}

+ (void)registerMechanismClass:(Class)mechanismClass forMechanismName:(NSString *)mechanismName
{
    [[self sasl_registeredMechanisms] setObject:mechanismClass forKey:mechanismName];
}

#pragma mark Mechanism Name

+ (NSString *)name
{
    return nil;
}

#pragma mark Authentication Exchange

- (void)beginAuthenticationExchangeWithHostname:(NSString *)hostname responseHandler:(void (^)(NSData *initialResponse, BOOL abort))responseHandler
{
    if (responseHandler) {
        responseHandler(nil, YES);
    }
}

- (void)handleChallenge:(NSString *)challenge responseHandler:(void (^)(NSData *, BOOL))responseHandler
{
    if (responseHandler) {
        responseHandler(nil, YES);
    }
}

#pragma mark Authentication Outcome

- (void)succeedWithData:(NSData *)data
{
}

- (void)failedWithError:(NSError *)error
{
}

@end
