//
//  PCShareViewController.h
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/24.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCViewController.h"

@interface PCShareViewController : PCViewController {
    
}

@property(nonatomic,strong)UIImage *image;
@property(nonatomic,weak)IBOutlet UIImageView *imageView;
@property(nonatomic,weak)IBOutlet UIButton    *shareButton;

@end
