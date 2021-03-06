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

#define PURCHASE_TRANSACTION @"PURCHASE_TRANSACTION"
#define RESTORE_TRANSACTION @"RESTORE_TRANSACTION"

#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

#define ALL_PRODUCT_ID @"com.appstudio1020.7.pro"

#define MONTH_ID @"com.appstudio1020.7.month"

#define YEAR_ID @"com.appstudio1020.7.year"

//广告产品id
#define AD_PRODUCT_ID @"com.appstudio1020.7.ad"

#define TRY_OR_NOT @"TRYORNOT"

#define HIDE_SETTING_ANIMATION @"HIDE_SETTING_ANIMATION"

#define APP_ID @"1039766045"

//需要显示的系统相册名字
#define SEARCH_ALBUM @[@"All Photos",@"Recents",@"Recently Added",@"Screenshots",@"所有照片", @"最近项目",@"最近項⽬",@"最近添加",@"最近加入",@"截屏",@"屏幕快照",@"截圖"]


//需要首要显示的相册名字
#define FIRST_ALBUM @[@"All Photos",@"Recents",@"所有照片", @"最近项目",@"最近項目"]

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
#define IS_AD_VERSION @"1"

//初始化编辑界面时候默认选择的特效项，从0开始计数，以1递增，第一项为0，第二项为1，若超出最大特效项默认为0。
#define DEFAULT_SELECT_EFFECT @"4"

//用户包年赠送免费试用的天数
#define TRY_DATE_COUNT @"7"

#endif /* Macro_h */
