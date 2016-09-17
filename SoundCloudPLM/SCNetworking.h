//
//  SCNetworking.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthState.h"
#import "AuthResult.h"

@interface SCNetworking : NSObject

@property (strong, nonatomic, readonly) OAuthState *state;

-(NSURLRequest *)makeAuthRequest;
-(AuthResult *)resultFromAuthResponse:(NSURL *)url;
-(BOOL)isOAuthResponse:(NSURL *)url;

@end
