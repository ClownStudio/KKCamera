//
//  PhotoEditCustomButton.h
//  PhotoX
//
//  Created by Leks on 2017/11/24.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "HCPhotoEditCustomButton.h"

@interface PhotoEditCustomButton : HCPhotoEditCustomButton

@property (nonatomic, strong) PhotoEditCustomButton *parentBtn;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *parent;
@property (nonatomic) CGRect destFrame;
-(id)initWithData:(NSDictionary*)data parent:(NSDictionary*)parent;
-(void)addProMask;
-(void)reloadData:(NSDictionary*)data parent:(NSDictionary*)parent;

-(void)addStickerProMask;

@end
