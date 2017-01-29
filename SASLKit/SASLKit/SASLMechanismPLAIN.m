//
//  SASLMechanismPLAIN.m
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


#import "SASLMechanismPLAIN.h"

@interface SASLMechanismPLAIN () {
    dispatch_queue_t _queue;
    NSString *_hostname;
    void (^_responseHandler)(NSData *response, BOOL abort);
    void (^_completion)(BOOL success, NSError *error);
}

@end

@implementation SASLMechanismPLAIN

+ (void)load
{
    [SASLMechanism registerMechanismClass:self
                         forMechanismName:[self name]];
}

#pragma mark Mechanism Name

+ (NSString *)name
{
    return @"PLAIN";
}

#pragma mark Life-cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("SASLMechanismPLAIN", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark Authenticate

- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    dispatch_async(_queue, ^{
        if (_responseHandler) {
            if (username && password) {

                _completion = completion;

                unsigned short nul[] = {0};

                NSMutableData *response = [[NSMutableData alloc] init];

                [response appendBytes:nul length:1];
                [response appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];

                [response appendBytes:nul length:1];
                [response appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];

                _responseHandler(response, NO);
            } else {

                _responseHandler(nil, YES);

                if (completion) {
                    NSString *errorMessage = [NSString stringWithFormat:@"Abort authentication for '%@', because either username or password is nil.", _hostname];
                    NSError *error = [NSError errorWithDomain:SASLMechanismErrorDomain
                                                         code:SASLMechanismErrorCodeNoCredentials
                                                     userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                    completion(NO, error);
                }
            }
            _responseHandler = nil;
        }
    });
}

- (void)abort
{
    dispatch_async(_queue, ^{
        if (_responseHandler) {

            _responseHandler(nil, YES);
            _responseHandler = nil;
        }
    });
}

#pragma mark Authentication Exchange

- (void)beginAuthenticationExchangeWithHostname:(NSString *)hostname responseHandler:(void (^)(NSData *, BOOL))responseHandler
{
    dispatch_async(_queue, ^{
        _hostname = hostname;
        _responseHandler = responseHandler;

        dispatch_queue_t queue = self.delegateQueue ?: dispatch_get_main_queue();
        dispatch_async(queue, ^{
            if ([self.delegate respondsToSelector:@selector(SASLMechanismNeedsCredentials:)]) {
                [self.delegate SASLMechanismNeedsCredentials:self];
            }
        });
    });
}

#pragma mark Authentication Outcome

- (void)succeedWithData:(NSData *)data
{
    dispatch_async(_queue, ^{
        if (_completion) {
            void (^completion)(BOOL success, NSError *error) = _completion;
            dispatch_queue_t queue = self.delegateQueue ?: dispatch_get_main_queue();
            dispatch_async(queue, ^{
                completion(YES, nil);
            });
            _completion = nil;
        }
    });
}

- (void)failedWithError:(NSError *)error
{
    dispatch_async(_queue, ^{
        if (_completion) {
            void (^completion)(BOOL success, NSError *error) = _completion;
            dispatch_queue_t queue = self.delegateQueue ?: dispatch_get_main_queue();
            dispatch_async(queue, ^{
                completion(NO, error);
            });
            _completion = nil;
        }
    });
}

@end
