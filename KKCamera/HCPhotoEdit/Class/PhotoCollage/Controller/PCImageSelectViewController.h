//
//  PCImageSelectViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/19.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCViewController.h"

@interface PCImageSelectViewController : PCViewController<UITableViewDelegate,UITableViewDataSource> {
    
}

@property(nonatomic,weak)IBOutlet UITableView *photosTableView;
@property(nonatomic,weak)IBOutlet UITableView *albumsTableView;
@property(nonatomic,weak)IBOutlet UIButton *albumNameButton;
@property(nonatomic,weak)IBOutlet UIButton *albumIconButton;
@property(nonatomic,weak)IBOutlet UILabel *numberLabel;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;

@end
