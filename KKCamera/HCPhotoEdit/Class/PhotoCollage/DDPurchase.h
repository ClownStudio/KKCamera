//
//  DDPurchase.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/5/8.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol DDPurchaseDelegate;

@interface DDPurchase : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

+ (DDPurchase *)purchase;

@property(nonatomic,assign)id<DDPurchaseDelegate> delegate;
@property(nonatomic,strong)NSArray<SKProduct *> *products;//获取的products
@property(nonatomic,strong)NSArray *invalidProducts;

- (NSString *)formattedPriceStringFromProduct:(SKProduct *)product;//格式化价格

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers;

- (void)payForProduct:(SKProduct *)product;//购买操作

- (BOOL)isProductPurchased:(NSString *)productId;

@end

@protocol DDPurchaseDelegate <NSObject>

@optional
- (void)purchaseDidGetProductInfo:(DDPurchase *)purchase;
- (void)purchaseDidSuccess:(DDPurchase *)purchase;
- (void)purchaseDidFail:(DDPurchase *)purchase;

@end
