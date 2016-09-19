//
//  Track.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "Track.h"

@implementation Track

-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    [self parseWithDict:dict];
    return self;
}

#pragma mark - Private JSON parsing

-(void)parseWithDict:(NSDictionary *)dict
{
    _playId = [dict valueForKey:@"id"];
    _title = [NSString stringWithString:[dict valueForKey:@"title"]];
    _image = [self urlForJSONValue:[dict valueForKey:@"artwork_url"]];
    if (_image) {
        NSString *u500 = [_image.absoluteString stringByReplacingOccurrencesOfString:@"large.jpg"
                                                                          withString:@"t500x500.jpg"];
        _image500 = [NSURL URLWithString:u500];
    } else {
        _image500 = nil;
    }
    _artist = [NSString stringWithString:[[dict valueForKey:@"user"] valueForKey:@"username"]];
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
