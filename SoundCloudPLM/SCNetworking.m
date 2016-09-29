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
@property (strong, nonatomic) RKObjectManager *manager;
@property (weak, nonatomic, readonly) NSDictionary *authParam;
@end

@implementation SCNetworking

+ (instancetype)sharedInstance
{
    static SCNetworking *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SCNetworking alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _state = [[OAuthState alloc] init];
        _playlists = [[NSMutableArray alloc] init];
        _findedTracks = [[NSMutableArray alloc] init];
        [self initRKNetwork];
    }
    return self;
}

#pragma mark - Playlists API

-(void)getPlaylists
{
    [self.manager getObjectsAtPath:@"/me/playlists"
                        parameters:self.authParam
                           success:
    ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_playlists removeAllObjects];
        [_playlists addObjectsFromArray:mappingResult.array];
        [self.delegate dataUpdateSuccess:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self.delegate dataUpdateSuccess:NO];
    }];
}

-(void)savePlaylist:(Playlist *)pl
{
    if (pl.playId) {
        [self.manager putObject:pl
                             path:[NSString stringWithFormat:@"/me/playlists/%@",pl.playId]
                       parameters:self.authParam
                          success:
         ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
             [self.delegate dataUpdateSuccess:YES];
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             [self.delegate dataUpdateSuccess:NO];
         }];
    } else {
        [self.manager postObject:pl
                            path:@"/playlists"
                      parameters:self.authParam
                         success:
         ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
             [self.delegate dataUpdateSuccess:YES];
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             [self.delegate dataUpdateSuccess:NO];
         }];
    }
}

-(void)createPlaylistNamed:(NSString *)name
{
    self.tempPlaylist = [[Playlist alloc] initTemporaryNamed:name];
}

#pragma mark - Tracks

-(void)clearSearchResults;
{
    [_findedTracks removeAllObjects];
    _searchText = @"";
    [self.delegate dataUpdateSuccess:YES];
}

-(void)searchTracksWithQuery:(NSString *)query
{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:self.authParam];
    [param setObject:query forKey:@"q"];
    [self.manager getObjectsAtPath:@"/tracks"
                        parameters:param
                           success:
     ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [_findedTracks removeAllObjects];
         [_findedTracks addObjectsFromArray:mappingResult.array];
         [self.delegate dataUpdateSuccess:YES];
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [self.delegate dataUpdateSuccess:NO];
     }];
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

-(NSDictionary *)authParam
{
    return @{ @"oauth_token" : self.authResult.value };
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

#pragma mark - RestKit Setup

-(void)initRKNetwork
{
    NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com"];
    self.manager = [RKObjectManager managerWithBaseURL:url];
    [self setResponseDescriptors];
    [self setRequestDescriptors];
}

-(void)setResponseDescriptors
{
    RKObjectMapping *trMapping = [RKObjectMapping mappingForClass:[Track class]];
    NSDictionary *trMap = @{
                            @"id": @"playId",
                            @"title": @"title",
                            @"artwork_url": @"image",
                            };
    [trMapping addAttributeMappingsFromDictionary:trMap];
    
    RKObjectMapping *plMapping = [RKObjectMapping mappingForClass:[Playlist class]];
    NSDictionary *plMap = @{
                            @"id": @"playId",
                            @"title": @"title",
                            @"artwork_url": @"image",
                            @"uri": @"uri",
                            };
    [plMapping addAttributeMappingsFromDictionary:plMap];
    [plMapping addRelationshipMappingWithSourceKeyPath:@"tracks" mapping:trMapping];
    
    NSIndexSet *successCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *rd = [RKResponseDescriptor
                                responseDescriptorWithMapping:plMapping
                                method:RKRequestMethodAny
                                pathPattern:nil //@"/me/playlists"
                                keyPath:nil
                                statusCodes:successCodes];
    
    [self.manager addResponseDescriptor:rd];
    
    RKResponseDescriptor *trd = [RKResponseDescriptor
                                 responseDescriptorWithMapping:trMapping
                                 method:RKRequestMethodGET
                                 pathPattern:@"/tracks"
                                 keyPath:nil
                                 statusCodes:successCodes];
    
    [self.manager addResponseDescriptor:trd];
}

-(void)setRequestDescriptors
{
    RKObjectMapping *trMapping = [RKObjectMapping requestMapping];
    NSDictionary *trMap = @{
                            @"playId": @"id",
                            };
    [trMapping addAttributeMappingsFromDictionary:trMap];
    
    RKObjectMapping *plMapping = [RKObjectMapping requestMapping];
    NSDictionary *plMap = @{
                            @"playId": @"id",
                            @"sharing": @"sharing",
                            @"title": @"title",
                            };
    [plMapping addAttributeMappingsFromDictionary:plMap];
    [plMapping addRelationshipMappingWithSourceKeyPath:@"tracks" mapping:trMapping];
    
    RKRequestDescriptor *rd = [RKRequestDescriptor
                               requestDescriptorWithMapping:plMapping
                               objectClass:[Playlist class]
                               rootKeyPath:@"playlist"
                               method:RKRequestMethodAny];
    
    [self.manager addRequestDescriptor:rd];
}

@end
