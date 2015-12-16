//
//  ItemListViewController.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "ItemListViewController.h"
#import "DataManager.h"

@interface ItemListViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *itemIds;
@property (nonatomic, strong) NSIndexPath *currentSelectedPath;
@end

@implementation ItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.action;
}

- (NSArray *)itemIds {
    if (!_itemIds) {
        NSArray *allIds = [DataManager sharedManager].itemInfo.allKeys;
        _itemIds = [allIds sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }
    return _itemIds;
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
        return self.itemIds.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = indexPath.section==0?@"coinCell":@"itemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"coins: %ld", (long)[DataManager sharedManager].coins];
    } else {
        NSString *itemId = self.itemIds[indexPath.row];
        NSDictionary *item = [DataManager sharedManager].itemInfo[itemId];
        cell.textLabel.text = itemId;
        cell.detailTextLabel.text = [[DataManager sharedManager].userItems[itemId] stringValue] ? : @"0";
        
        UILabel *accLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        accLb.textAlignment = NSTextAlignmentCenter;
        accLb.backgroundColor = [UIColor colorWithRed:0.133f green:0.451f blue:0.969f alpha:1.00f];
        accLb.textColor = [UIColor whiteColor];
        if ([self.action isEqualToString:@"购买物品"]) {
            accLb.text = [NSString stringWithFormat:@"%@ coins", item[@"price"]];
        } else {
            accLb.text = @"使用";
        }
        cell.accessoryView = accLb;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelectedPath = indexPath;
    if ([self.action isEqualToString:@"购买物品"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"购买物品" message:@"输入您要购买的物品的数量" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"购买", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alert textFieldAtIndex:0] setText:@"1"];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"购买物品" message:@"输入您要使用的物品的数量" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"使用", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alert textFieldAtIndex:0] setText:@"1"];
        [alert show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *itemId = self.itemIds[self.currentSelectedPath.row];
    if (buttonIndex == alertView.cancelButtonIndex) {
        
    } else {
        UITextField *textField = [alertView textFieldAtIndex:0];
        int amount = [textField.text intValue];
        if (amount > 0) {
            if ([self.action isEqualToString:@"购买物品"]) {
                NSDictionary *item = [DataManager sharedManager].itemInfo[itemId];
                NSInteger cost = [item[@"price"] integerValue] * amount;
                if ([DataManager sharedManager].coins < cost) {
                    NSLog(@"钱不够");
                } else {
                    [[DataManager sharedManager] buyItem:itemId count:amount];
                }
            } else {
                NSInteger itemCount = [[DataManager sharedManager].userItems[itemId] integerValue];
                if (itemCount > 0) {
                    [[DataManager sharedManager] useItem:itemId amount:amount];
                } else {
                    NSLog(@"没有物品【%@】了", itemId);
                }
            }
            [self.tableView reloadData];
        }
    }
    self.currentSelectedPath = nil;
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

