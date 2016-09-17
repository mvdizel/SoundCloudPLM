//
//  OAuthState.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "OAuthState.h"

@implementation OAuthState

-(instancetype)init {
    self = [super init];
    _clientId       = @"fdcc64d02a458d73fca99478e8c539f3";
    _clientSecret   = @"09a368c9bc150575f3f1cba51d6840f0";
    _redirectUri    = @"oauth://oauth-callback/soundcloud";
    _responseType   = @"token";
    _display        = @"popup";
    _connectURL     = [NSURL URLWithString:@"https://soundcloud.com/connect/"];
    _tokenURL       = [NSURL URLWithString:@"https://api.soundcloud.com/oauth2/token"];
    return self;
}

@end
