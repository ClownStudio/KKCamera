//
//  Macro.h
//  FTCamera
//
//  Created by 张文洁 on 2018/7/30.
//  Copyright © 2018年 JamStudio. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define kStoreProductKey [NSString stringWithFormat:@"storeProduct%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

#define TERMS_OF_USE @"http://instagram.com"
#define PRIVACY_POLICY @"http://instagram.com"
#define SEARCH_ALBUM @[@"Camera Roll", @"Screenshots", @"Recently Added", @"All Photos",@"最近项目",@"截屏"]
#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

#define ALL_PRODUCT_ID [NSString stringWithFormat:@"%@.pro",[[NSBundle mainBundle] bundleIdentifier]]

#define MONTH_ID [NSString stringWithFormat:@"%@.month",[[NSBundle mainBundle] bundleIdentifier]]

#define YEAR_ID [NSString stringWithFormat:@"%@.year",[[NSBundle mainBundle] bundleIdentifier]]

#define TRY_OR_NOT @"TRYORNOT"
#define TRY_DATE_COUNT @"7"

#define HIDE_SETTING_ANIMATION @"HIDE_SETTING_ANIMATION"

#define APP_ID @"1039766045"

//广告产品id
#define AD_PRODUCT_ID @"com.appstudio.X2.ad"
//应⽤程式ID
#define AD_APP_ID @"ca-app-pub-3553919144267977~5799280260"
//插⻚广告ID
#define AD_INTERSTITIAL_ID @"ca-app-pub-3553919144267977/7659156843"
//横幅广告ID
#define AD_BANNER_ID @"ca-app-pub-3553919144267977/1668463564"
//奖励广告ID
#define AD_AWARD_ID @"ca-app-pub-3553919144267977/8358952851"

//广告展示时间间隔（秒）
#define CameraShowAdTime 60

//是否解锁后才可保存 0为是 1为否
#define IS_SAVED_UNLOCK @"0"

//是否显示广告 0为是 1为否
#define IS_AD_VERSION @"0"

#endif /* Macro_h */
