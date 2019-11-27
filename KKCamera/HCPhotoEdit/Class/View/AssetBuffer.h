//
//  AssetBuffer.h
//  PhotoX
//
//  Created by Leks on 2017/11/27.
//  Copyright © 2017年 idea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotoEditCustomButton.h"

@interface AssetBuffer : NSObject

@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, strong) NSMutableDictionary *configFile;
@property (nonatomic, strong) NSMutableArray *buttons;

- (UIImage*)imageForName:(NSString*)filename;
- (NSMutableArray*)configDataForName:(NSString*)filename;

+(id)sharedInstance;

- (void)loadHalo;
- (void)loadBorder;
- (void)loadSticker;

- (void)loadButtons;
- (void)loadImages;
-(PhotoEditCustomButton*)dequeButtonWithData:(NSDictionary*)data parent:(NSDictionary*)parent;
-(void)recycleButtons:(NSArray*)btns;
@end
