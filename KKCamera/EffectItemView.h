//
//  EffectItemView.h
//  KKCamera
//
//  Created by Jam Zhang on 2019/12/18.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EffectItemView : UIView

- (void)setItemWithData:(NSDictionary *)dict;
- (void)setItemSelected:(BOOL)isSelect;
@property (nonatomic,assign)BOOL isAward;

@end

NS_ASSUME_NONNULL_END
