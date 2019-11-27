//
//  PhotoEditCustomButton.m
//  PhotoX
//
//  Created by Leks on 2017/11/24.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "PhotoEditCustomButton.h"
#import "HCPhotoEditBaseItemView.h"
#import "AssetBuffer.h"
#import "GPUImage.h"

@implementation PhotoEditCustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithData:(NSDictionary*)data parent:(NSDictionary*)parent
{
    if (self = [super initWithImage:data[@"acv"]?data[@"acvImage"]:[[AssetBuffer sharedInstance] imageForName:data[@"icon"]]
                   highlightedImage:data[@"acv"]?data[@"acvImage"]:[[AssetBuffer sharedInstance] imageForName:data[@"icon"]]
                              title:data[@"name"]
                               font:10
                          imageSize:55])
    {
        self.data = data;
        self.parent = parent;
        [self setImage:data[@"acv"]?data[@"acvImage"]:[[AssetBuffer sharedInstance] imageForName:data[@"icon"]] forState:UIControlStateSelected];
    }
    
    return self;
}

-(void)reloadData:(NSDictionary*)data parent:(NSDictionary*)parent
{
    _image = [[AssetBuffer sharedInstance] imageForName:data[@"icon"]];
    if (!_image && data[@"acv"]) {
        _image = data[@"acvImage"];
    }
    _hightImage = _image;
    self.normalState = YES;
    _title = data[@"name"];
    
    [self setImage:_image forState:UIControlStateNormal];
    [self setImage:_hightImage forState:UIControlStateHighlighted];
    [self setImage:_hightImage forState:UIControlStateSelected];
    [self setTitle:data[@"name"] forState:UIControlStateNormal];
    self.data = data;
    self.parent = parent;
}

-(void)addProMask
{
    CGFloat offset = 0;
    if (Is_iPhoneX) {
        offset = 3;
    }
    
    UIImageView *pro_mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purchase_pro_black.png"]];
    pro_mask.userInteractionEnabled = NO;
    
    CGRect r = pro_mask.frame;
    r.size.width = 30;
    r.size.height = 30;
    r.origin.x = CGRectGetMaxX(self.bounds) - r.size.width - 17;
    r.origin.y = self.bounds.origin.y + 10 + offset;
    pro_mask.frame = r;
    
    [self addSubview:pro_mask];
}

-(void)addStickerProMask
{
    CGFloat offset = 0;
    if (Is_iPhoneX) {
        offset = 3;
    }
    
    UIImageView *pro_mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purchase_pro_black.png"]];
    pro_mask.userInteractionEnabled = NO;
    
    CGRect r = pro_mask.frame;
    r.size.width = 30;
    r.size.height = 30;
    r.origin.x = CGRectGetMaxX(self.bounds) - r.size.width - 17;
    r.origin.y = self.bounds.origin.y + 10 + offset;
    pro_mask.frame = r;
    
    [self addSubview:pro_mask];
}


@end
