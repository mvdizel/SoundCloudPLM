//
//  PlayListsViewCell.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListsViewCell.h"

@interface PlayListsViewCell ()
//@property (strong, nonatomic) NSURL *currentURL;
@end

@implementation PlayListsViewCell

-(void)updateImageWithUrl:(NSURL *)url andPlaylist:(Track *)pl
{
    if (!pl.downloadedImage) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            dispatch_sync(dispatch_get_main_queue(), ^{
                pl.downloadedImage = imageData;
                [self setTrackImage:imageData];
            });
        });
    } else {
        [self setTrackImage:pl.downloadedImage];
    }
}

-(void)setTrackImage:(NSData *)imageData
{
    UIImage *downloadedImage = [UIImage imageWithData:imageData];
    [self.imageView setImage:downloadedImage];
    [self setNeedsLayout];
}

@end
