//
//  ProManager.m
//  PhotoX
//
//  Created by Leks on 2017/11/21.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "ProManager.h"

@implementation ProManager

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (id)init
{
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)restorePro
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)buyProduct:(NSString *)productId
{
    self.currentProductId = productId;
    if ([SKPaymentQueue canMakePayments]) {
        [self getProductInfo:productId];
        NSLog(@"Start purchase：%@", productId);
    } else {
        if ([self.delegate respondsToSelector:@selector(didFailedBuyProduct:forReason:)])
        {
            [self.delegate didFailedBuyProduct:self.currentProductId forReason:NSLocalizedString(@"DisablePurchases", nil)];
        }
    }
}

//从Apple查询用户点击购买的产品的信息
- (void)getProductInfo:(NSString *)productIdentifier {
    NSArray *product = [[NSArray alloc] initWithObjects:productIdentifier, nil];
    NSSet *set = [NSSet setWithArray:product];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        NSLog(@"Failed purchase：%@", self.currentProductId);
        if ([self.delegate respondsToSelector:@selector(didFailedBuyProduct:forReason:)]) {
            [self.delegate didFailedBuyProduct:self.currentProductId forReason:NSLocalizedString(@"UnablePurchases", nil)];
        }
        return;
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    NSLog(@"Ongoing purchase：%@", self.currentProductId);
}

//查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didFailedBuyProduct:forReason:)]) {
        [self.delegate didFailedBuyProduct:self.currentProductId forReason:NSLocalizedString(@"UnablePurchases", nil)];
    }
}

//购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored://已经购买过该商品
                break;
                
            case SKPaymentTransactionStatePurchasing://商品添加进列表
            {
                NSLog(@"Requesting payment：%@", self.currentProductId);
            }
                break;
                
            default:
                break;
        }
    }
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Purchase successful：%@", transaction.payment.productIdentifier);
    [ProManager addProductId:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    if ([self.delegate respondsToSelector:@selector(didSuccessBuyProduct:)]) {
        [self.delegate didSuccessBuyProduct:self.currentProductId];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Failed purchase：%@", transaction.error);
    if(transaction.error.code != SKErrorPaymentCancelled) {
        if ([self.delegate respondsToSelector:@selector(didFailedBuyProduct:forReason:)]) {
            [self.delegate didFailedBuyProduct:transaction.payment.productIdentifier forReason:NSLocalizedString(@"UnablePurchases", nil)];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didCancelBuyProduct:)]) {
            [self.delegate didCancelBuyProduct:self.currentProductId];
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Restore：");
    [ProManager addProductId:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    if ([self.delegate respondsToSelector:@selector(didSuccessRestoreProducts:)]) {
        [self.delegate didSuccessRestoreProducts:@[transaction.payment.productIdentifier]];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSMutableArray *purchasedProducts = [NSMutableArray array];
    NSLog(@"received restored transactions: %zd", queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedProducts addObject:productID];
        [ProManager addProductId:productID];
        NSLog(@"%@",productID);
    }
    if ([self.delegate respondsToSelector:@selector(didSuccessRestoreProducts:)]) {
        [self.delegate didSuccessRestoreProducts:purchasedProducts];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%@", error.localizedDescription);
    if (error.localizedDescription) {
        ;
    }
    if ([self.delegate respondsToSelector:@selector(didFailRestore:)]) {
        [self.delegate didFailRestore:@"Restore failed"];
    }
}

+(BOOL)canPay
{
    return [SKPaymentQueue canMakePayments];
}

+(BOOL)isProductPaid:(NSString*)productId
{
    NSString *key = @"paid_products";
    NSArray *paid_products = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
    
    if (!paid_products) {
        return NO;
    }
    
    for (int i=0; i<paid_products.count; i++) {
        NSString *pid = paid_products[i];
        if ([pid isEqualToString:productId]) {
            return YES;
        }
    }
    
    return NO;
}

+(void)addProductId:(NSString*)productId
{
    NSMutableArray *ma = [NSMutableArray array];
    NSString *key = @"paid_products";
    NSArray *paid_products = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
    
    if (paid_products) {
        [ma setArray:paid_products];
    }
    
    for (int i=0; i<paid_products.count; i++) {
        NSString *pid = paid_products[i];
        if ([pid isEqualToString:productId]) {
            return;
        }
    }
    
    if (productId) [ma addObject:productId];
    [[NSUserDefaults standardUserDefaults] setValue:ma forKey:key];
}

+(BOOL)isFullPaid
{
    return [self isProductPaid:kProDeluxeId];
}

+(NSArray*)haloItems
{
    NSMutableArray *halo = [NSMutableArray array];
    
#pragma mark 封面1
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [item setDictionary:@{@"isPurchase":@YES,
                          @"name":@"Leak",
                          @"icon":@"halo_cover_1.png",
                          @"productId":@"com.puti104.N007.1"
                          }];
    NSMutableArray *sub_items = [NSMutableArray array];
    [sub_items addObject:@{@"isPurchase":@NO,
                             @"name":@"Leak 1",
                             @"icon":@"halo_icon1_1.png",
                             @"source":@"halo_1_1.png"
                             }];
    [sub_items addObject:@{@"isPurchase":@YES,
                           @"name":@"Leak 2",
                           @"icon":@"halo_icon1_2.png",
                           @"source":@"halo_1_2.png"
                           }];
    [sub_items addObject:@{@"isPurchase":@YES,
                           @"name":@"Leak 3",
                           @"icon":@"halo_icon1_3.png",
                           @"source":@"halo_1_3.png"
                           }];
    [sub_items addObject:@{@"isPurchase":@YES,
                           @"name":@"Leak 4",
                           @"icon":@"halo_icon1_4.png",
                           @"source":@"halo_1_4.png"
                           }];
    [sub_items addObject:@{@"isPurchase":@YES,
                           @"name":@"Leak 5",
                           @"icon":@"halo_icon1_5.png",
                           @"source":@"halo_1_5.png"
                           }];
    
    return halo;
}
@end
