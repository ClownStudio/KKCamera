//
//  PCTextViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/23.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCViewController.h"
#import "FXLabel.h"

@protocol PCTextViewControllerDelegate;

@interface PCTextViewController : PCViewController <UITextFieldDelegate> {
    
}

@property(nonatomic,weak)IBOutlet UIView *mainView;
@property(nonatomic,weak)IBOutlet UIButton *keyboardButton;
@property(nonatomic,weak)IBOutlet UIButton *fontButton;
@property(nonatomic,weak)IBOutlet UIButton *colorButton;
@property(nonatomic,weak)IBOutlet UIButton *artFontButton;
@property(nonatomic,weak)IBOutlet UIButton *doneButton;
@property(nonatomic,weak)IBOutlet UITextField *textFiled;
@property(nonatomic,weak)IBOutlet UILabel     *label;
@property(nonatomic,weak)IBOutlet FXLabel     *fxLabel;

@property(nonatomic,assign)id<PCTextViewControllerDelegate> delegate;

- (void)show;
- (void)hidden;

@end

@protocol PCTextViewControllerDelegate <NSObject>

@optional
- (void)textViewControllerDidDoneAction:(PCTextViewController *)viewController;

@end
