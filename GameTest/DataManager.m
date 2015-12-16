//
//  DataManager.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "DataManager.h"
#import <MaxLeap/MaxLeap.h>

#define High_Mission @"as.leap.game.ana.test.highestMission"
#define User_Item @"as.leap.game.ana.test.userItems"
#define User_Coins @"as.leap.game.ana.test.userCoins"

@implementation DataManager

+ (instancetype)sharedManager {
    static DataManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DataManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.itemInfo = @{
                          @"物品1":@{
                                  @"type":@"type1",
                                  @"price":@10
                                  },
                          @"物品2":@{
                                  @"type":@"type2",
                                  @"price":@20
                                  },
                          @"物品3":@{
                                  @"type":@"type3",
                                  @"price":@30
                                  }
                          };
        self.missionInfo = @{
                             @"关卡1": @{
                                     @"mid":@"关卡1",
                                     @"type":@"较易",
                                     @"reward":@{
                                             @"item":@{
                                                     @"物品1":@1,
                                                     @"物品2":@1,
                                                     @"物品3":@1
                                                     }
                                             }
                                     },
                             @"关卡2": @{
                                     @"mid":@"关卡2",
                                     @"type":@"较易",
                                     @"reward":@{
                                             @"coins":@100
                                             }
                                     },
                             @"关卡3": @{
                                     @"mid":@"关卡3",
                                     @"type":@"一般",
                                     @"reward":@{
                                             @"coins":@50,
                                             @"itemr":@"11"
                                             }
                                     },
                             @"关卡4": @{
                                     @"mid":@"关卡4",
                                     @"type":@"较难"
                                     },
                             @"关卡5": @{
                                     @"mid":@"关卡5",
                                     @"type":@"较难"
                                     }
                             };
        self.missionList = @[@"关卡1",@"关卡2",@"关卡3",@"关卡4",@"关卡5"];
        self.highest = [[NSUserDefaults standardUserDefaults] integerForKey:High_Mission];
        self.userItems = [[[NSUserDefaults standardUserDefaults] objectForKey:User_Item] mutableCopy];
        if (!self.userItems) {
            self.userItems = [NSMutableDictionary dictionary];
        }
        self.coins = [[NSUserDefaults standardUserDefaults] integerForKey:User_Coins];
    }
    return self;
}

- (void)passMission:(NSString *)missionId {
    self.highest = [self.missionList indexOfObject:missionId] +1;
    [[NSUserDefaults standardUserDefaults] setInteger:self.highest forKey:High_Mission];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)increaseCoins:(NSInteger)count {
    self.coins += count;
    [[NSUserDefaults standardUserDefaults] setInteger:self.coins forKey:User_Coins];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)consumeCoins:(NSInteger)count {
    if (count > self.coins) {
        [NSException raise:NSInternalInconsistencyException format:@"has not enough coins"];
    }
    self.coins -= count;
    [[NSUserDefaults standardUserDefaults] setInteger:self.coins forKey:User_Coins];
}

- (void)rewardCoins:(NSInteger)count reason:(NSString *)reason {
    [self increaseCoins:count];
    [MLGAVirtureCurrency onReward:count reason:reason];
}

- (void)increaseItem:(NSString *)itemId byAmount:(NSUInteger)amount {
    NSUInteger count = [self.userItems[itemId] unsignedIntegerValue];
    count += amount;
    self.userItems[itemId] = @(count);
    [[NSUserDefaults standardUserDefaults] setObject:self.userItems forKey:User_Item];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)consumeItem:(NSString *)itemId byAmount:(NSUInteger)amount {
    NSUInteger count = [self.userItems[itemId] unsignedIntegerValue];
    count -= amount;
    self.userItems[itemId] = @(count);
    [[NSUserDefaults standardUserDefaults] setObject:self.userItems forKey:User_Item];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)rewardItem:(NSString *)itemId count:(int)count reason:(NSString *)reason {
    [self increaseItem:itemId byAmount:count];
    NSDictionary *item = self.itemInfo[itemId];
    [MLGAItem onReward:itemId itemType:item[@"type"] itemCount:count reason:reason];
}

- (void)buyItem:(NSString *)itemId count:(int)count {
    NSDictionary *item = self.itemInfo[itemId];
    NSInteger cost = [item[@"price"] integerValue] * count;
    
    [self consumeCoins:cost];
    [self increaseItem:itemId byAmount:count];
    
    [MLGAItem onPurchase:itemId itemCount:count itemType:item[@"type"] virtualCurrency:cost];
}

- (void)useItem:(NSString *)itemId amount:(int)amount {
    [self consumeItem:itemId byAmount:amount];
    
    NSDictionary *item = self.itemInfo[itemId];
    [MLGAItem onUse:itemId itemType:item[@"type"] itemCount:amount];
}

@end
