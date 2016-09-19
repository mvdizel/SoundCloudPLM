//
//  SCNetworking.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "SCNetworking.h"

@interface SCNetworking ()
@property (strong, nonatomic) AuthResult* authResult;
@property (strong, nonatomic, readwrite) NSMutableArray *playlists;
@end

@implementation SCNetworking

-(instancetype)init
{
    self = [super init];
    _state = [[OAuthState alloc] init];
    _playlists = [[NSMutableArray alloc] init];
    return self;
}

#pragma mark - Playlists API

-(NSURLRequest *)makePlaylistsRequest
{
    NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/me/playlists"];
    NSURLComponents *comp = [NSURLComponents componentsWithURL:url
                                       resolvingAgainstBaseURL:YES];
    
    NSMutableArray *qi = [[NSMutableArray alloc] init];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"oauth_token" value:self.authResult.value]];
    comp.queryItems = qi;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:comp.URL];
    
    return request;
}

-(NSURLRequest *)makeNewPlaylistsRequestNamed:(NSString *)name
{
    NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/playlists.json"];
    NSURLComponents *comp = [NSURLComponents componentsWithURL:url
                                       resolvingAgainstBaseURL:YES];

    NSMutableArray *qi = [[NSMutableArray alloc] init];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"oauth_token" value:self.authResult.value]];
    comp.queryItems = qi;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:comp.URL];
    request.HTTPMethod = @"POST";
    
//    NSDictionary *newPL = @{@"title":name,@"sharing":@"public",@"tracks":@[]};
    NSDictionary *newPL = @{@"title":name,@"sharing":@"public"};//,@"tracks":@[]};
    NSDictionary *gistDict = @{@"playlist":newPL};
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:gistDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
    
    [request setHTTPBody:jsonData];
    
    return request;
}

-(void)getPlaylists
{
    NSURLRequest *request = [self makePlaylistsRequest];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:request.URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [self updatePlaylistsFromJSON:json];
                [self.delegate dataUpdated];
            }] resume];
}

-(void)createPlaylistNamed:(NSString *)name
{
    NSURLRequest *request = [self makeNewPlaylistsRequestNamed:name];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                [self.delegate dataUpdated];
//                NSLog([NSString stringWithFormat:@"resp url %@", response.URL]);
                NSLog([NSString stringWithFormat:@"resp %@", response]);
                NSLog([NSString stringWithFormat:@"err %@", error]);
            }] resume];
}

-(void)updatePlaylistsFromJSON:(NSArray *)json
{
    [_playlists removeAllObjects];
    for (int i = 0; i < json.count; i++) {
        Playlist *pl = [[Playlist alloc] initWithDict:json[i]];
        [_playlists addObject:pl];
    }
}

#pragma mark - Authentication

-(NSURLRequest *)makeAuthRequest
{
    NSURLComponents *comp = [NSURLComponents componentsWithURL:self.state.connectURL
                                       resolvingAgainstBaseURL:YES];
    
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
        self.authResult = nil;
    } else if ([self.state.responseType isEqualToString:@"token"]) {
        self.authResult = [self retrieveToken:url];;
    } else {
        self.authResult = [self retrieveCode:url];
    }
    return self.authResult;
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
    for (NSString *values in [fragment componentsSeparatedByString:@"&"])
    {
        NSArray *param = [values componentsSeparatedByString:@"="];
        if(param.count == 2 && [param.firstObject isEqualToString:value])
        {
            return param.lastObject;
        }
    }
    return nil;
}

@end
