//
//  PCShareViewController.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/24.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCShareViewController.h"
#import "TKAlertCenter.h"
#import "DDImage.h"

@interface PCShareViewController ()<UIActionSheetDelegate>

@end

@implementation PCShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageView.image = _image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)shareAction:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Please select output size" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Small",@"Normal",@"High", nil];
    [actionSheet showInView:self.view];
    
//    UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[_image] applicationActivities:nil];
//    [viewController setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
//        [[DDWaitingView sharedView]stopAnimation];
//        if (activityError) {
//            [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Save fail,Please try again!"];
//        }
//        else  if (completed){
//            [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Save successfully!"];
//        }
//    }];
//    
//    // Show loading spinner after a couple of seconds
//    double delayInSeconds = 0.1f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [[DDWaitingView sharedView]setText:@""];
//        [[DDWaitingView sharedView]startAnimation];
//    });
//    if ([viewController respondsToSelector:@selector(popoverPresentationController)]) {
//        viewController.popoverPresentationController.sourceView = self.shareButton;
//        viewController.popoverPresentationController.sourceRect = self.shareButton.bounds;
//    }
//    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3) {
        return;
    }
    CGFloat scale = 1.0f;
    if (buttonIndex == 0) {
        scale = 0.33;
    }
    else if (buttonIndex == 1) {
        scale = 0.75;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = self.image;
        if (buttonIndex < 2) {
            image = [DDImage scaleThumbnailWithImage:self.image outputSize:CGSizeMake(_image.size.width * scale, _image.size.height * scale)];
        }
        
        UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        [viewController setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
//            [[DDWaitingView sharedView]stopAnimation];
            if (activityError) {
                [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Save fail,Please try again!"];
            }
            else  if (completed){
                [[TKAlertCenter defaultCenter]postAlertWithMessage:@"Save successfully!"];
            }
        }];
        
        // Show loading spinner after a couple of seconds
//        [[DDWaitingView sharedView]setText:@""];
//        [[DDWaitingView sharedView]startAnimation];
        
        // Show
        //    [viewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        //
        //    }];
        if ([viewController respondsToSelector:@selector(popoverPresentationController)]) {
            viewController.popoverPresentationController.sourceView = self.shareButton;
            viewController.popoverPresentationController.sourceRect = self.shareButton.bounds;
        }
        [self presentViewController:viewController animated:YES completion:nil];
    });
}

@end
