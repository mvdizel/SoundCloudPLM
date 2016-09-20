//
//  PlayListViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 18.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "PlayListViewController.h"
#import "PlayListViewCell.h"
#import "TrackDetailsViewController.h"
#import "SearchTracksViewController.h"

@interface PlayListViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *playlistImage;
@end

@implementation PlayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)setup
{
//    [self.networkong updateTracksForPL:self.playlist];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.playlist.image500]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.playlistImage setImage:downloadedImage];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlist.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    
    Track *tr = self.playlist.tracks[indexPath.row];
    cell.titleLabel.text = tr.title;
    cell.artistLabel.text = tr.artist;
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)(indexPath.row + 1)];
    [cell updateImageWithUrl:tr.image];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TracksDetailsSegue"]) {
        TrackDetailsViewController *cont = segue.destinationViewController;
        cont.networkong = self.networkong;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        cont.track = self.playlist.tracks[indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"SearchSegue"]) {
        SearchTracksViewController *cont = segue.destinationViewController;
        cont.networkong = self.networkong;
        cont.playlist = self.playlist;
    }
}

@end
