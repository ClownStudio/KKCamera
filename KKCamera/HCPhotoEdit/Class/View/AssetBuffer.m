//
//  AssetBuffer.m
//  PhotoX
//
//  Created by Leks on 2017/11/27.
//  Copyright © 2017年 idea. All rights reserved.
//

#import "AssetBuffer.h"
#import "ProManager.h"

@implementation AssetBuffer

- (id)init
{
    if (self = [super init]) {
        self.images = [NSMutableDictionary dictionary];
        self.configFile = [NSMutableDictionary dictionary];
        self.buttons = [NSMutableArray array];
        
        [self loadHalo];
        [self loadBorder];
        [self loadSticker];
        [self loadAcvFilter];
    }
    
    return self;
}

- (void)loadHalo
{
    [self loadConfig:@"Halo"];
}

- (void)loadBorder
{
    [self loadConfig:@"Border"];
}

- (void)loadSticker
{
    [self loadConfig:@"Sticker"];
}

- (void)loadAcvFilter
{
    [self loadConfig:@"Filters"];
}

- (void)loadConfig:(NSString*)filename
{
    NSString *border_path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSArray *config = [NSArray arrayWithContentsOfFile:border_path];
    NSMutableArray *ma = [NSMutableArray array];
    
    for (int i=0; i<config.count; i++)
    {
        NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:config[i]];
        NSString *sub_file_path = [[NSBundle mainBundle] pathForResource:md[@"sub_file_name"] ofType:@"plist"];
        NSArray *sub_config = [NSArray arrayWithContentsOfFile:sub_file_path];

        md[@"expanded"] = @NO;
        md[@"isParent"] = @YES;
        if ([ProManager isProductPaid:md[@"productId"]] || [ProManager isFullPaid]) {
            md[@"paid"] = @YES;
        }
        else
        {
            md[@"paid"] = @NO;
        }
        
//        UIImage *img = [UIImage imageNamed:md[@"icon"]];
//        if (img) self.images[md[@"icon"]] = img;
        
        NSMutableArray *sub_items = [NSMutableArray array];
        for (int j=0; j<sub_config.count; j++) {
            NSDictionary *tmp = sub_config[j];
            NSMutableDictionary *sub = [NSMutableDictionary dictionaryWithDictionary:tmp];
            sub[@"parent"] = md;
            [sub_items addObject:sub];
        }
        
        md[@"sub_items"] = sub_items;
        [ma addObject:md];
    }
    
    self.configFile[filename] = ma;
}

- (void)loadImages
{
    NSLog(@"start load halo images");
    NSArray *halos = self.configFile[@"Halo"];
    for (int i=0; i<halos.count; i++)
    {
        NSDictionary *md = halos[i];
        UIImage *img = [UIImage imageNamed:md[@"icon"]];
        if (img) self.images[md[@"icon"]] = img;
        
        NSArray *sub_items = md[@"sub_items"];
        for (int j=0; j<sub_items.count; j++) {
            NSDictionary *sub = sub_items[j];
            UIImage *img = [UIImage imageNamed:sub[@"icon"]];
            if (img) self.images[sub[@"icon"]] = img;
        }
    }
    NSLog(@"finished halo");
    
    NSLog(@"start load border images");
    halos = self.configFile[@"Border"];
    for (int i=0; i<halos.count; i++)
    {
        NSDictionary *md = halos[i];
        UIImage *img = [UIImage imageNamed:md[@"icon"]];
        if (img) self.images[md[@"icon"]] = img;
        
        NSArray *sub_items = md[@"sub_items"];
        for (int j=0; j<sub_items.count; j++) {
            NSDictionary *sub = sub_items[j];
            UIImage *img = [UIImage imageNamed:sub[@"icon"]];
            if (img) self.images[sub[@"icon"]] = img;
        }
    }
    NSLog(@"finished border");
    
    NSLog(@"start load sticker images");
    halos = self.configFile[@"Sticker"];
    for (int i=0; i<halos.count; i++)
    {
        NSDictionary *md = halos[i];
        UIImage *img = [UIImage imageNamed:md[@"icon"]];
        if (img) self.images[md[@"icon"]] = img;
        
        NSArray *sub_items = md[@"sub_items"];
        for (int j=0; j<sub_items.count; j++) {
            NSDictionary *sub = sub_items[j];
            UIImage *img = [UIImage imageNamed:sub[@"icon"]];
            if (img) self.images[sub[@"icon"]] = img;
        }
    }
    NSLog(@"finished sticker");
}

- (UIImage*)imageForName:(NSString*)filename
{
    if (self.images[filename]) {
        return self.images[filename];
    }
    
    return [UIImage imageNamed:filename];
}

- (NSMutableArray*)configDataForName:(NSString*)filename
{
    return self.configFile[filename];
}

+(id)sharedInstance
{
    static AssetBuffer *__sAssetBuffer = nil;
    
    if (!__sAssetBuffer) {
        __sAssetBuffer = [[AssetBuffer alloc] init];
    }
    return __sAssetBuffer;
}

- (void)loadButtons
{
    NSLog(@"start load buttons");
    int count = 50;
    for (int i=0; i<count; i++) {
        PhotoEditCustomButton *btn  = [[PhotoEditCustomButton alloc] initWithData:@{} parent:@{}];
        [self.buttons addObject:btn];
    }
    NSLog(@"finish load buttons");
}

-(PhotoEditCustomButton*)dequeButtonWithData:(NSDictionary*)data parent:(NSDictionary*)parent
{
    if (self.buttons.count > 0) {
        PhotoEditCustomButton *btn = [self.buttons lastObject];
        [btn reloadData:data parent:parent];
        [self.buttons removeLastObject];
        return btn;
    }
    
    PhotoEditCustomButton *btn  = [[PhotoEditCustomButton alloc] initWithData:data parent:parent];
    return btn;
}

-(void)recycleButtons:(NSArray*)btns
{
    [self.buttons addObjectsFromArray:btns];
}

@end
