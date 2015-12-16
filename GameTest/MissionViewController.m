//
//  MissionViewController.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "MissionViewController.h"
#import "DataManager.h"
#import "ItemListViewController.h"
#import <MaxLeap/MaxLeap.h>

@interface MissionViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *menus;
@end

@implementation MissionViewController

- (void)awakeFromNib {
    self.menus = @[@"购买金币",@"购买物品",@"使用物品",@"冲关成功",@"冲关失败",@"暂停冲关"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.mid;
    self.navigationItem.hidesBackButton = YES;
    
    [self onBegin];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)exit:(id)sender {
    // 放弃
    [self onFailedWithReason:@"quit"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"item"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        [(ItemListViewController *)segue.destinationViewController setAction:self.menus[indexPath.row]];
    }
}

#pragma mark -

- (void)forwardToNext {
    NSInteger mission = [[DataManager sharedManager].missionList indexOfObject:self.mid];
    self.mid = [DataManager sharedManager].missionList[mission +1];
    self.title = self.mid;
    [self onBegin];
}

- (void)onBegin {
    NSDictionary *mission = [DataManager sharedManager].missionInfo[self.mid];
    [MLGAMission onBegin:self.mid type:mission[@"type"]];
}

- (void)onPause {
    [MLGAMission onPause:self.mid];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"暂停中" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alert.tag = 103;
    [alert show];
}

- (void)onResume {
    [MLGAMission onResume:self.mid];
}

- (void)onComplete {
    [MLGAMission onCompleted:self.mid];
    [[DataManager sharedManager] passMission:self.mid];
    
    // reward
    NSDictionary *reward = [DataManager sharedManager].missionInfo[self.mid][@"reward"];
    NSString *reason = [NSString stringWithFormat:@"通过%@", self.mid];
    if (reward[@"coins"]) {
        [[DataManager sharedManager] rewardCoins:[reward[@"coins"] integerValue] reason:reason];
    }
    if (reward[@"item"]) {
        [(NSDictionary *)reward[@"item"] enumerateKeysAndObjectsUsingBlock:^(NSString *itemId, NSNumber *amount, BOOL *stop) {
            [[DataManager sharedManager] rewardItem:itemId count:[amount intValue] reason:reason];
        }];
    }
    if ([reward[@"itemr"] isEqualToString:@"11"]) { // 随机一种物品
        NSArray *itemIdList = [DataManager sharedManager].itemInfo.allKeys;
        double randomNumber = (double)arc4random() / (UINT_MAX+1LL); // 获取 [0, 1) 区间内的一个随机数
        int index = randomNumber * itemIdList.count;
        NSString *iid = itemIdList[index];
        [[DataManager sharedManager] rewardItem:iid count:1 reason:reason];
    }
}

- (void)onFailedWithReason:(NSString *)reason {
    [MLGAMission onFailed:self.mid failedCause:reason];
}

#pragma mark - table view data source and delegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return []
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.menus[indexPath.row];
    cell.textLabel.textColor = [UIColor blueColor];
    
    if (indexPath.row == 0) {
        UILabel *accLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        accLb.textAlignment = NSTextAlignmentCenter;
        accLb.backgroundColor = [UIColor colorWithRed:0.133f green:0.451f blue:0.969f alpha:1.00f];
        accLb.textColor = [UIColor whiteColor];
        accLb.text = [@([DataManager sharedManager].coins) stringValue];
        cell.accessoryView = accLb;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: // 购买金币
            [self performSegueWithIdentifier:@"coin" sender:indexPath];
            break;
        case 1: // 购买物品
            [self performSegueWithIdentifier:@"item" sender:indexPath];
            break;
        case 2: // 使用物品
            [self performSegueWithIdentifier:@"item" sender:indexPath];
            break;
        case 3: // 冲关成功
        {
            [self onComplete];
            if ([[DataManager sharedManager].missionList.lastObject isEqualToString:self.mid]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"冲关成功" message:@"恭喜！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重玩", @"返回", nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"冲关成功" message:@"恭喜！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重玩", @"返回", @"下一关", nil];
                [alert show];
            }
        }
            break;
        case 4: // 冲关失败
        {
            [self onFailedWithReason:@"failed"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"冲关失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"重玩", @"返回", nil];
            [alert show];
        }
            break;
        case 5: // 暂停冲关
        {
            [self onPause];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 103) {
        [self onResume];
        return;
    }
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // 重玩
        [self onBegin];
    } else if (buttonIndex == alertView.firstOtherButtonIndex +1) {
        // 返回
        [self.navigationController popViewControllerAnimated:YES];
    } else if (buttonIndex == alertView.firstOtherButtonIndex +2) {
        // 下一关
        [self forwardToNext];
    }
}

@end
