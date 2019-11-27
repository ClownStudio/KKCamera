//
//  ProManager.h
//  PhotoX
//
//  Created by Leks on 2017/11/21.
//  Copyright © 2017年 idea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Macro.h"

#define kProDeluxeId ALL_PRODUCT_ID

//内购测试id
//帐号：test@appstudio.com
//密码：Hw20171122
//#define kProDeluxeId    @"vc.youme.tt1"

@protocol ProManagerDelegate <NSObject>

-(void)didSuccessBuyProduct:(NSString*)productId;
-(void)didSuccessRestoreProducts:(NSArray*)productIds;
-(void)didFailRestore:(NSString*)reason;
-(void)didFailedBuyProduct:(NSString*)productId forReason:(NSString*)reason;
-(void)didCancelBuyProduct:(NSString*)productId;
@end

@interface ProManager : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>
{
    
}
@property (nonatomic, assign) id <ProManagerDelegate> delegate;
@property (nonatomic, strong) NSString *currentProductId;
- (void)buyProduct:(NSString*)productId;
- (void)restorePro;

+(BOOL)canPay;
+(BOOL)isProductPaid:(NSString*)productId;
+(void)addProductId:(NSString*)productId;
+(BOOL)isFullPaid;


@end
