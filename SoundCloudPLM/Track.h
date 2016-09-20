//
//  Track.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (strong, nonatomic, readonly) NSNumber *playId;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *artist;
@property (strong, nonatomic, readonly) NSURL *image;
@property (strong, nonatomic, readonly) NSURL *image500;
@property (strong, nonatomic) NSData *downloadedImage;

-(instancetype)initWithDict:(NSDictionary *)dict;

@end
