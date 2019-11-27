//
//  DDPurchase.m
//  PhotoCollage
//
//  Created by Winnie on 16/5/8.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "DDPurchase.h"

DDPurchase *_gPurchase;

@implementation DDPurchase

+ (DDPurchase *)purchase
{
    @synchronized (self) {
        if (!_gPurchase) {
            _gPurchase = [[DDPurchase alloc]init];
        }
    }
    return _gPurchase;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    }
    return self;
}

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers {
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)payForProduct:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment]; 
}

- (BOOL)isProductPurchased:(NSString *)productId
{
    if (!productId) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults]boolForKey:productId];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    self.products = response.products;
    
    NSMutableArray *invalidPorducts = [NSMutableArray array];
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        // Handle any invalid product identifiers. 处理有效的ProductIdentifiers, 缺货的，错误的不能有!
        [invalidPorducts addObject:invalidIdentifier];
    }
    self.invalidProducts = invalidPorducts;
    
    if ([self.delegate respondsToSelector:@selector(purchaseDidGetProductInfo:)]) {
        [self.delegate purchaseDidGetProductInfo:self];
    }
}

- (NSString *)formattedPriceStringFromProduct:(SKProduct *)product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

#pragma mark - SKPaymentTransactionObserver

/*
 1. SKPaymentTransactionStatePurchasing: 购买中，此时可更新UI来展现购买的过程。
 2. SKPaymentTransactionStateFailed: 购买错误，此时要根据错误的代码给用户相应的提示。
 3. SKPaymentTransactionStatePurchased: 购买成功，此时要提供给用户相应的内容。
 4. SKPaymentTransactionStateRestored: 恢复已购产品，此时需要将已经购买的商品恢复给用户。
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased: // 购买成功
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed: // 购买失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored: // 恢复已购
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
//    NSString * productIdentifier = transaction.payment.productIdentifier;
//    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
//    if ([productIdentifier length] > 0) {
//        // 向自己的服务器验证购买凭证
//    }
    // Remove the transaction from the payment queue.
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if ([self.delegate respondsToSelector:@selector(purchaseDidSuccess:)]) {
        [self.delegate purchaseDidSuccess:self];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Failed purchase");
    } else {
        NSLog(@"User cancels the transaction");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if ([self.delegate respondsToSelector:@selector(purchaseDidFail:)]) {
        [self.delegate purchaseDidFail:self];
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 恢复已经购买的产品
    //[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self completeTransaction:transaction];
}

@end
