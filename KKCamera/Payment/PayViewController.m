//
//  PayViewController.m
//  PhotoX
//
//  Created by Leks on 2017/11/21.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PayViewController.h"
#import "ProManager.h"

@interface PayViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@end


@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.proManager = [[ProManager alloc] init];
    self.proManager.delegate = self;
    
    [self.img sizeToFit];
    
    CGRect r = self.img.frame;
    if (r.size.width > self.view.frame.size.width - 80) {
        r.size.width = self.view.frame.size.width - 80;
        r.size.height = r.size.height = self.img.image.size.height / self.img.image.size.width * r.size.width;
    }
    
    self.img.frame = r;
    
    self.img.center = self.view.center;
    self.btn.frame = self.img.frame;
    self.closeBtn.center = self.img.center;
    
    r = self.closeBtn.frame;
    r.origin.y = self.img.frame.origin.y - self.closeBtn.frame.size.height;
    self.closeBtn.frame = r;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)buyAction:(id)sender
{
    
    [self showLoading];
    [self.proManager restorePro];
    
}

-(void)didSuccessBuyProduct:(NSString*)productId
{
    [self showMessage:@"Purchase success,thank you!"];
    [self performSelector:@selector(closeAction:) withObject:nil afterDelay:3.0f];
}

-(void)didSuccessRestoreProducts:(NSArray*)productIds
{
    if ([ProManager isFullPaid])
    {
        //全解锁
        [self showMessage:@"Restore success"];
        [self performSelector:@selector(closeAction:) withObject:nil afterDelay:3.0f];
        return ;
    }
    
    //未买过，进行支付
    [self.proManager buyProduct:kProDeluxeId];
}

-(void)didFailRestore:(NSString *)reason
{
    [self.proManager buyProduct:kProDeluxeId];
}
-(void)didFailedBuyProduct:(NSString*)productId forReason:(NSString*)reason
{
    [self showMessage:reason];
}

-(void)didCancelBuyProduct:(NSString*)productId
{
    [self hideHUD];
}

- (void)showMessage:(NSString*)msg
{
    if (self.hud) {
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = msg;
    
    [self.hud hide:YES afterDelay:3.0];
}

- (void)showLoading
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHUD
{
    [self.hud hide:YES];
}

- (void)delayDismiss
{
    
}
@end
