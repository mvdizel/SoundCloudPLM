//
//  Playlist.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "Playlist.h"

@interface Playlist ()
@property (strong, nonatomic, readwrite) NSMutableArray *tracks;
@end

@implementation Playlist

-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    _tracks = [[NSMutableArray alloc] init];
    [self parseWithDict:dict];
    return self;
}

#pragma mark - Private JSON parsing

-(void)parseWithDict:(NSDictionary *)dict
{
    _playId = [dict valueForKey:@"id"];
    _title = [NSString stringWithString:[dict valueForKey:@"title"]];
    _image = [self urlForJSONValue:[dict valueForKey:@"artwork_url"]];
    
    [_tracks removeAllObjects];
    for (NSDictionary *track in [dict valueForKey:@"tracks"]) {
        [_tracks addObject:[[Track alloc] initWithDict:track]];
    }
    
    if (!_image && _tracks.count != 0) {
        _image = [_tracks.firstObject valueForKey:@"image"];
    }
}

-(NSURL *)urlForJSONValue:(id)value
{
    if ([self isNilValue:value]
        || ![value isKindOfClass:[NSString class]]
        || [(NSString *)value length] == 0) {
        return nil;
    }
    return [NSURL URLWithString:(NSString *)value];
}

-(BOOL)isNilValue:(id)value
{
    return (value == [NSNull null] || value == nil);
}

@end
