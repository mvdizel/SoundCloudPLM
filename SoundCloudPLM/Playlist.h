//
//  Playlist.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

@interface Playlist : NSObject

@property (strong, nonatomic, readonly) NSNumber *playId;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSURL *image;
@property (strong, nonatomic, readonly) NSURL *image500;
@property (strong, nonatomic, readonly) NSArray *tracks;

-(instancetype)initWithDict:(NSDictionary *)dict;
-(void)parseWithDict:(NSDictionary *)dict;
-(void)addTrack:(Track *)track;

@end
