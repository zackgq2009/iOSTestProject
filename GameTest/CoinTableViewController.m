//
//  CoinTableViewController.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "CoinTableViewController.h"
#import "PurchaseManager.h"
#import "DataManager.h"

@interface CoinTableViewController ()
//@property (nonatomic, strong) 
@end

@implementation CoinTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        return [PurchaseManager sharedManager].productList.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = indexPath.section==0?@"coinCell":@"prodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = [@([DataManager sharedManager].coins) stringValue];
    } else {
        NSString *pid = [PurchaseManager sharedManager].productList[indexPath.row];
        NSDictionary *product = [PurchaseManager sharedManager].productInfo[pid];
        cell.textLabel.text = [product[@"coins"] stringValue];
        
        UILabel *accLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        accLb.textAlignment = NSTextAlignmentCenter;
        accLb.backgroundColor = [UIColor colorWithRed:0.133f green:0.451f blue:0.969f alpha:1.00f];
        accLb.textColor = [UIColor whiteColor];
        accLb.text = [NSString stringWithFormat:@"%@%@", product[@"cs"], product[@"price"]];
        cell.accessoryView = accLb;
        
        cell.accessibilityLabel = accLb.text;
    }
    
    return cell;
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSString *pid = [PurchaseManager sharedManager].productList[indexPath.row];
        NSDictionary *product = [PurchaseManager sharedManager].productInfo[pid];
        [[PurchaseManager sharedManager] purchaseProduct:pid block:^(BOOL success, NSError *error) {
            if (success) {
                [[DataManager sharedManager] increaseCoins:[product[@"coins"] integerValue]];
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
