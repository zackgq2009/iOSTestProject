//
//  PurchaseManager.h
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PurchaseManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSDictionary *productInfo;
@property (nonatomic, strong) NSArray *productList;

@property (nonatomic, strong) NSString *currentOrderId;
@property (nonatomic, strong) NSString *currentPid;
@property (nonatomic, strong) void(^completionBlock)(BOOL success, NSError *error);

+ (instancetype)sharedManager;

- (void)purchaseProduct:(NSString *)pid block:(void(^)(BOOL success, NSError *error))block;

@end
