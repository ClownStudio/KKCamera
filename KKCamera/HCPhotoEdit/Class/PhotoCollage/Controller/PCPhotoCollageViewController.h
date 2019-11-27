//
//  PCPhotoCollageViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/20.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCViewController.h"

@interface PCPhotoCollageViewController : PCViewController<UITableViewDelegate,UITableViewDataSource> {
    
}

@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;
@property(nonatomic,weak)IBOutlet UIView       *maskView;
@property(nonatomic,weak)IBOutlet UIView       *mainView;
@property(nonatomic,weak)IBOutlet UITableView  *tableView;
@property(nonatomic,weak)IBOutlet UIButton     *resetButton;
@property(nonatomic,weak)IBOutlet UIButton     *effectButton;
@property(nonatomic,weak)IBOutlet NSLayoutConstraint *constraint;
@end
