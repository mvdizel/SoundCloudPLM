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
@property (strong, nonatomic) SCNetworking *networkong;
@end

@implementation SearchTracksViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkong = [SCNetworking sharedInstance];
    self.networkong.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.networkong.delegate = self;
    if (self.networkong.searchText && self.networkong.searchText.length > 0) {
        self.searchBar.text = self.networkong.searchText;
    }
}

- (void) dismissKeyboard
{
    [self.searchBar resignFirstResponder];
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
    [cell updateImageWithUrl:tr.image andTrack:tr];
    
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
    [self dismissKeyboard];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.networkong clearSearchResults];
    [self.tableView reloadData];
    [self dismissKeyboard];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.networkong searchTracksWithQuery:searchText];
}

-(void)dataUpdateSuccess:(BOOL)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
