//
//  DDToolsSystemPhotos.h
//  DDToolsSystemPhotos
//
//  Created by 杜若川 on 13-7-17.
//  Copyright (c) 2013年 杜若川. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

extern NSString * const DDToolsSystemAlbumDidFinishLoad;/*加载系统资源完成发出的通知消息*/
extern NSString * const DDToolsSystemAlbumFailLoad;//加载失败

@protocol DDToolsSystemAlbumDelegate;

@interface DDToolsSystemAlbum : NSObject{
    @private
    ALAssetsLibrary     * _assetsLibrary;
    NSMutableArray      * _photoAssets;
    NSMutableArray      * _videoAssets;
    
    NSMutableArray      * _groupNames;
    NSMutableDictionary * _photoAlbums;
}

@property(nonatomic,assign)id<DDToolsSystemAlbumDelegate>delegate;
@property(nonatomic,copy)NSString * savedPhotosGroupName;

+ (DDToolsSystemAlbum *)sharedAlbum;

/*刷新数据*/
- (void)loadData;

#pragma mark - Deprecated Use Read From _photoAssets&_videoAssets
- (NSInteger)photosCount;
- (UIImage*)photoThumbnailAtIndex:(NSInteger)index;
- (UIImage*)photoImageAtIndex:(NSInteger)index;
- (UIImage*)originPhotoImageAtIndex:(NSInteger)index;
- (NSURL*)photoUrlAtIndex:(NSInteger)index;
- (UIImage*)posterImage;
- (NSInteger)videosCount;
- (UIImage*)videoThumbnailAtIndex:(NSInteger)index;
- (NSString*)videoTitleAtIndex:(NSInteger)index;
- (NSURL*)videoUrlAtIndex:(NSInteger)index;
- (NSTimeInterval)videoDurationAtIndex:(NSInteger)index;
- (ALAssetRepresentation*)videoRepresentationAtIndex:(NSInteger)index;
- (ALAsset*)photoALAssetAtIndex:(NSInteger)Index;

#pragma mark - Read From Album
- (NSArray *)albums;//相册名称
- (NSInteger)imageCountInAlbumWithName:(NSString *)albumName;
- (UIImage *)thumbnailFromAlbumWithName:(NSString *)albumName atIndex:(NSInteger)index;//缩略图
- (UIImage *)imageFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index;//满屏图
- (UIImage *)originImageFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index;//原图
- (NSDate *)imageDateFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index;
- (ALAsset *)photoALAssetFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index;

- (NSURL *)imageURLFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index;
@end

@protocol DDToolsSystemAlbumDelegate <NSObject>

@optional
- (void)toolsSystemAlbumDidFinishLoad:(DDToolsSystemAlbum *)systemAlbum;
- (BOOL)toolsSystemAlbumValidAsset:(ALAsset *)asset type:(NSString *)assetType;

@end
