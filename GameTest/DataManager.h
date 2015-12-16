//
//  DataManager.h
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSDictionary *missionInfo;
@property (nonatomic, strong) NSDictionary *itemInfo;

@property (nonatomic, strong) NSArray *missionList;

@property (nonatomic) NSInteger highest;
@property (nonatomic, strong) NSMutableDictionary *userItems;
@property (nonatomic) NSInteger coins;

+ (instancetype)sharedManager;

- (void)passMission:(NSString *)missionId;

- (void)increaseCoins:(NSInteger)count;
- (void)rewardCoins:(NSInteger)count reason:(NSString *)reason;

- (void)buyItem:(NSString *)itemId count:(int)count;
- (void)rewardItem:(NSString *)itemId count:(int)count reason:(NSString *)reason;
- (void)useItem:(NSString *)itemId amount:(int)amount;

@end
