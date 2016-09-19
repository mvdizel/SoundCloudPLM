//
//  PlayListViewCell.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageTrackView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

-(void)updateImageWithUrl:(NSURL *)url;

@end
