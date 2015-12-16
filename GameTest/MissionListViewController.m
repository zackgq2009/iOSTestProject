//
//  MissionListViewController.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "MissionListViewController.h"
#import "DataManager.h"
#import "MissionViewController.h"

@interface MissionListViewController ()
@property (nonatomic,strong) NSString *selectedMission;
@end

@implementation MissionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <= [DataManager sharedManager].highest) {
        self.selectedMission = [DataManager sharedManager].missionList[indexPath.row];
        [self performSegueWithIdentifier:@"mission" sender:[tableView cellForRowAtIndexPath:indexPath]];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [DataManager sharedManager].missionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MissionCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [DataManager sharedManager].missionList[indexPath.row];
    
    if (indexPath.row <= [DataManager sharedManager].highest) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"mission"]) {
        MissionViewController *vc = (MissionViewController *)segue.destinationViewController;
        vc.mid = self.selectedMission;
    }
}


@end
