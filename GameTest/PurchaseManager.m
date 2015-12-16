//
//  PurchaseManager.m
//  GameTest
//
//  Created by Sun Jin on 7/22/15.
//  Copyright (c) 2015 leap. All rights reserved.
//

#import "PurchaseManager.h"
#import <MaxLeap/MaxLeap.h>

@implementation PurchaseManager

+ (instancetype)sharedManager {
    static PurchaseManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PurchaseManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.productInfo = @{
                             @"p1":@{
                                     @"pid":@"p1",
                                     @"price":@0.99,
                                     @"cc":@"USD",  // currency code
                                     @"cs":@"$",    // currency symbol
                                     @"coins":@100
                                     },
                             @"p2":@{
                                     @"pid":@"p1",
                                     @"price":@4.99,
                                     @"cc":@"USD",
                                     @"cs":@"$",
                                     @"coins":@1000
                                     },
                             @"p3":@{
                                     @"pid":@"p1",
                                     @"price":@9.99,
                                     @"cc":@"USD",
                                     @"cs":@"$",
                                     @"coins":@3000
                                     },
                             @"p4":@{
                                     @"pid":@"p1",
                                     @"price":@19.99,
                                     @"cc":@"USD",
                                     @"cs":@"$",
                                     @"coins":@8000
                                     },
                             @"p5":@{
                                     @"pid":@"p1",
                                     @"price":@49.99,
                                     @"cc":@"USD",
                                     @"cs":@"$",
                                     @"coins":@25000
                                     },
                             };
        self.productList = @[@"p1", @"p2", @"p3", @"p4", @"p5"];
    }
    return self;
}

- (void)purchaseProduct:(NSString *)pid block:(void(^)(BOOL success, NSError *error))block {
    NSDictionary *product = self.productInfo[pid];
    NSAssert(product!=nil, nil);
    NSString *orderId = [[NSUUID UUID] UUIDString];
    double curAmount = [product[@"price"] integerValue];
    [MLGAVirtureCurrency onChargeRequest:nil orderId:orderId currencyAmount:curAmount currencyType:product[@"cc"] virtualCurrencyAmount:[product[@"coins"] integerValue] paySource:@"app store"];
    
    self.completionBlock = block;
    self.currentOrderId = orderId;
    self.currentPid = pid;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Buy Coins"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"成功", @"失败", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)clearCurrentOrder {
    self.currentOrderId = nil;
    self.currentPid = nil;
    self.completionBlock = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSError *error = nil;
    if (buttonIndex == alertView.cancelButtonIndex) {
        // 取消
        error = [NSError errorWithDomain:@"PurchaseErrorDomain" code:-998 userInfo:@{NSLocalizedDescriptionKey:@"cancelled"}];
        [MLGAVirtureCurrency onChargeCancelled:nil orderId:self.currentOrderId];
    } else if (buttonIndex == alertView.firstOtherButtonIndex) {
        // 成功
        [MLGAVirtureCurrency onChargeSuccess:nil orderId:self.currentOrderId];
    } else if (buttonIndex == alertView.firstOtherButtonIndex +1) {
        // 失败
        error = [NSError errorWithDomain:@"PurchaseErrorDomain" code:-999 userInfo:@{NSLocalizedDescriptionKey:@"unknown"}];
        [MLGAVirtureCurrency onChargeFailed:nil orderId:self.currentOrderId];
    }
    self.completionBlock(error==nil, error);
    [self clearCurrentOrder];
}

@end
