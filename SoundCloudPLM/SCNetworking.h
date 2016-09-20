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
#import "Playlist.h"

@protocol SCNetworkingDelegate <NSObject>
-(void)dataUpdated;
@end

@interface SCNetworking : NSObject

@property (strong, nonatomic, readonly) OAuthState *state;
@property (strong, nonatomic, readonly) NSArray *playlists;
@property (strong, nonatomic, readonly) NSArray *findedTracks;
@property (weak, nonatomic) id<SCNetworkingDelegate> delegate;

-(NSURLRequest *)makeAuthRequest;
-(AuthResult *)resultFromAuthResponse:(NSURL *)url;
-(void)getPlaylists;
-(BOOL)isOAuthResponse:(NSURL *)url;
-(void)createPlaylistNamed:(NSString *)name;
-(void)updateTracksForPL:(Playlist *)pl;
-(void)searchTracksWithQuery:(NSString *)query;
-(void)clearSearchResults;

@end
