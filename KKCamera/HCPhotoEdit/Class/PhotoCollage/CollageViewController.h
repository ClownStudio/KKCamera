//
//  ViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/6.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollageViewController : PCViewController <UITableViewDelegate,UITableViewDataSource>{
    
}

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@end

