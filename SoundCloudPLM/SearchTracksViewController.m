//
//  SearchTracksViewController.m
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 19.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import "SearchTracksViewController.h"
#import "PlayListViewCell.h"

@interface SearchTracksViewController () <UITableViewDelegate, UISearchBarDelegate, SCNetworkingDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation SearchTracksViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.networkong.findedTracks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    
    Track *tr = self.networkong.findedTracks[indexPath.row];
    cell.titleLabel.text = tr.title;
    cell.artistLabel.text = tr.artist;
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)(indexPath.row + 1)];
    [cell updateImageWithUrl:tr.image];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playlist addTrack:self.networkong.findedTracks[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearch delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.networkong searchTracksWithQuery:searchBar.text];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.networkong clearSearchResults];
    [self.tableView reloadData];
}

-(void)dataUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
