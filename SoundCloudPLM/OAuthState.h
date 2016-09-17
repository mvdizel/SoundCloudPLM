//
//  OAuthState.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthState : NSObject
@property (strong, nonatomic, readonly) NSString *clientId;
@property (strong, nonatomic, readonly) NSString *clientSecret;
@property (strong, nonatomic, readonly) NSString *redirectUri;
@property (strong, nonatomic, readonly) NSString *display;
@property (strong, nonatomic, readonly) NSString *responseType;
@property (strong, nonatomic, readonly) NSURL *connectURL;
@property (strong, nonatomic, readonly) NSURL *tokenURL;
@end
