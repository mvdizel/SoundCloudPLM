//
//  SCNetworking.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "SCNetworking.h"

@implementation SCNetworking

-(instancetype)init
{
    self = [super init];
    _state = [[OAuthState alloc] init];
    return self;
}

#pragma mark - Authentication

-(NSURLRequest *)makeAuthRequest
{
    NSURLComponents *comp = [NSURLComponents componentsWithURL:self.state.connectURL resolvingAgainstBaseURL:YES];
    NSMutableArray *qi = [[NSMutableArray alloc] init];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"client_id" value:self.state.clientId]];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"client_secret" value:self.state.clientSecret]];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"response_type" value:self.state.responseType]];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"redirect_uri" value:self.state.redirectUri]];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"display" value:self.state.display]];
    comp.queryItems = qi;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:comp.URL];
    
    return request;
}

-(BOOL)isOAuthResponse:(NSURL *)url
{
    return [self isRedirectToApp:url];
}

-(AuthResult *)resultFromAuthResponse:(NSURL *)url
{
    if (![self isRedirectToApp:url]) {
        return nil;
    } else if ([self.state.responseType isEqualToString:@"token"]) {
        return [self retrieveToken:url];;
    } else {
        return [self retrieveCode:url];
    }
}

#pragma mark - Private

-(BOOL)isRedirectToApp:(NSURL *)url
{
    NSString *ourScheme = [NSURL URLWithString:self.state.redirectUri].scheme;
    if (ourScheme != nil) {
        NSString *redirectScheme = url.scheme;
        return [ourScheme isEqualToString:redirectScheme];
    }
    return YES;
}

-(AuthResult *)retrieveToken:(NSURL *)url
{
    NSString *value = [self parameterValue:@"access_token" fromFragment:url.fragment];
    if (!value) {
        return nil;
    }
    AuthResult *ar = [[AuthResult alloc] init];
    ar.responseType = @"token";
    ar.value = value;
    return ar;
}

-(AuthResult *)retrieveCode:(NSURL *)url
{
    NSString *value = [self parameterValue:@"code" fromFragment:url.fragment];
    if (!value) {
        return nil;
    }
    AuthResult *ar = [[AuthResult alloc] init];
    ar.responseType = @"code";
    ar.value = value;
    return ar;
}

-(NSString *)parameterValue:(NSString *)value fromFragment:(NSString *)fragment
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [fragment componentsSeparatedByString:@"&"]) {
        NSArray *values = [param componentsSeparatedByString:@"="];
        if([values count] < 2) continue;
        [params setObject:[values lastObject] forKey:[values firstObject]];
    }
    
    return [params valueForKey:value];
}

@end
