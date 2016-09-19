//
//  PlayListsViewCell.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListsViewCell.h"

@implementation PlayListsViewCell

-(void)updateImageWithUrl:(NSURL *)url
{
    if (!self.imageView.image) {
        [self.spinner startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.imageView setImage:downloadedImage];
                [self.spinner stopAnimating];
            });
        });
    }
}

@end
