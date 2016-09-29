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
    if (self) {
        _tracks = [[NSMutableArray alloc] init];
        [self parseWithDict:dict];
    }
    return self;
}

-(instancetype)initTemporaryNamed:(NSString *)name
{
    self = [super init];
    _tracks = [[NSMutableArray alloc] init];
    _title = name;
    return self;
}

-(void)parseWithDict:(NSDictionary *)dict
{
    _playId = [dict valueForKey:@"id"];
    _title = [NSString stringWithString:[dict valueForKey:@"title"]];
    self.image = [self urlForJSONValue:[dict valueForKey:@"artwork_url"]];
    _uri = [self urlForJSONValue:[dict valueForKey:@"uri"]];
    
    [_tracks removeAllObjects];
    for (NSDictionary *track in [dict valueForKey:@"tracks"]) {
        [_tracks addObject:[[Track alloc] initWithDict:track]];
    }
    
    if (!_image && _tracks.count != 0) {
        self.image = [_tracks.firstObject valueForKey:@"image"];
    }
}

-(void)addTrack:(Track *)track
{
    [_tracks addObject:track];
}

-(void)delTrackAtIndex:(long)index
{
    [_tracks removeObjectAtIndex:index];
}

-(NSString *)sharing
{
    return @"public";
}

#pragma mark - Private

-(void)setTracks:(NSMutableArray *)tracks
{
    _tracks = tracks;
    if (!_image && _tracks.count != 0) {
        self.image = [_tracks.firstObject valueForKey:@"image"];
    }
}

-(void)setImage:(NSURL *)image
{
    _image = image;
    if (_image) {
        NSString *u500 = [_image.absoluteString stringByReplacingOccurrencesOfString:@"large.jpg"
                                                                          withString:@"t500x500.jpg"];
        _image500 = [NSURL URLWithString:u500];
    } else {
        _image500 = nil;
    }
}

#pragma mark - JSON parsing

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
