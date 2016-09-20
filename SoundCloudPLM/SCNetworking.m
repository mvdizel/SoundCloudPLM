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
@property (strong, nonatomic, readwrite) Playlist *tempPlaylist;
@property (strong, nonatomic, readwrite) NSMutableArray *findedTracks;
@end

@implementation SCNetworking

-(instancetype)init
{
    self = [super init];
    if (self) {
        _state = [[OAuthState alloc] init];
        _playlists = [[NSMutableArray alloc] init];
        _findedTracks = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Playlists API

-(void)updateTracksForPL:(Playlist *)pl
{
    NSURLRequest *request = [self makePlaylistsRequestWithId:pl.playId];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:request.URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [pl parseWithDict:json];
                [self.delegate dataUpdated];
            }] resume];
}

-(NSURLRequest *)makePlaylistsRequestWithId:(NSNumber *)id
{
    NSString *urlStr = [NSString stringWithFormat:@"https://api.soundcloud.com/me/playlists/%@",id];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLComponents *comp = [NSURLComponents componentsWithURL:url
                                       resolvingAgainstBaseURL:YES];
    
    NSMutableArray *qi = [[NSMutableArray alloc] init];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"oauth_token" value:self.authResult.value]];
    comp.queryItems = qi;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:comp.URL];
    
    return request;
}

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

-(NSURLRequest *)makeSavePlaylistsRequest:(Playlist *)pl
{
    NSString *plURL = @"https://api.soundcloud.com/playlists";
    if (pl.playId) {
        plURL = [pl.uri absoluteString];//[NSString stringWithFormat:@"%@/%@", plURL, pl.playId];
    }
    NSURL *url = [NSURL URLWithString:plURL];
    NSURLComponents *comp = [NSURLComponents componentsWithURL:url
                                       resolvingAgainstBaseURL:YES];

    NSMutableArray *qi = [[NSMutableArray alloc] init];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"oauth_token" value:self.authResult.value]];
    comp.queryItems = qi;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:comp.URL];
    request.HTTPMethod = @"POST";
    
//    NSDictionary *newPL = @{@"title":name,@"sharing":@"public",@"tracks":@[]};
    NSMutableDictionary *newPL = [NSMutableDictionary new];
    [newPL setValue:pl.title forKey:@"title"];
    [newPL setValue:@"sharing" forKey:@"sharing"];
    NSMutableArray *tracks = [NSMutableArray new];
    for (Track *track in pl.tracks) {
        [tracks addObject:@{@"id":[track.playId stringValue]}];
    }
    [newPL setValue:tracks forKey:@"tracks"];
    
    NSDictionary *jsonDict = @{@"playlist":newPL};
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
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
    self.tempPlaylist = [[Playlist alloc] initTemporaryNamed:name];
}

-(void)savePlaylist:(Playlist *)pl
{
    NSURLRequest *request = [self makeSavePlaylistsRequest:pl];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    [self.delegate dataUpdated];
//                NSLog([NSString stringWithFormat:@"resp url %@", response.URL]);
//                    NSLog([NSString stringWithFormat:@"resp %@", response]);
//                    NSLog([NSString stringWithFormat:@"err %@", error]);
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

#pragma mark - Tracks

-(void)clearSearchResults;
{
    [_findedTracks removeAllObjects];
    _searchText = @"";
    [self.delegate dataUpdated];
}

-(NSURLRequest *)makeSearchRequestWithQuery:(NSString *)query
{
    NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/tracks"];
    NSURLComponents *comp = [NSURLComponents componentsWithURL:url
                                       resolvingAgainstBaseURL:YES];
    
    NSMutableArray *qi = [[NSMutableArray alloc] init];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"oauth_token" value:self.authResult.value]];
    [qi addObject:[NSURLQueryItem queryItemWithName:@"q" value:query]];
    comp.queryItems = qi;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:comp.URL];
    
    return request;
}

-(void)searchTracksWithQuery:(NSString *)query
{
    _searchText = query;
    NSURLRequest *request = [self makeSearchRequestWithQuery:query];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:request.URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [_findedTracks removeAllObjects];
                for (NSDictionary *dict in json) {
                    [_findedTracks addObject:[[Track alloc] initWithDict:dict]];
                }
                [self.delegate dataUpdated];
            }] resume];
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
