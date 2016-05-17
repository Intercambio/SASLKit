//
//  SASLMechanismPLAIN.h
//  SASLKit
//
//  Created by Tobias Kraentzer on 17.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "SASLMechanism.h"

@interface SASLMechanismPLAIN : SASLMechanism

#pragma mark Authenticate

- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
                      completion:(void (^)(BOOL success, NSError *error))completion;

- (void)abort;

@end
