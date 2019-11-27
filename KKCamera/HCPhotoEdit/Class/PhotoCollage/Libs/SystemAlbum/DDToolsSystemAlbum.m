//
//  DDToolsSystemPhotos.m
//  DDToolsSystemPhotos
//
//  Created by 杜若川 on 13-7-17.
//  Copyright (c) 2013年 杜若川. All rights reserved.
//

#import "DDToolsSystemAlbum.h"

static DDToolsSystemAlbum  * _systemAlbum;

@implementation DDToolsSystemAlbum

NSString * const DDToolsSystemAlbumDidFinishLoad = @"DDToolsSystemAlbumDidFinishLoad";
NSString * const DDToolsSystemAlbumFailLoad      = @"DDToolsSystemAlbumFailLoad";

+ (DDToolsSystemAlbum *)sharedAlbum
{
    @synchronized(self){
        if (!_systemAlbum) {
            _systemAlbum = [[DDToolsSystemAlbum alloc]init];
        }
    }
    return _systemAlbum;
}

- (void)dealloc
{
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
        _videoAssets   = [[NSMutableArray alloc]init];
        _photoAssets   = [[NSMutableArray alloc]init];
        _photoAlbums   = [[NSMutableDictionary alloc]init];
        _groupNames    = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark - Reload Data
- (void)loadData
{
    /*Clear*/
    [_videoAssets removeAllObjects];
    [_photoAssets removeAllObjects];
    [_photoAlbums removeAllObjects];
    [_groupNames removeAllObjects];
    
    NSComparator comparisonBlock = ^NSComparisonResult(id obj1, id obj2){
        ALAsset * asset1 = (ALAsset *)obj1;
        ALAsset * asset2 = (ALAsset *)obj2;
        NSDate * date1 = [asset1 valueForProperty:ALAssetPropertyDate];
        NSDate * date2 = [asset2 valueForProperty:ALAssetPropertyDate];
        if ([date1 isEqualToDate:[date1 earlierDate:date2]]) {
            return NSOrderedDescending;
        }
        else if ([date2 isEqualToDate:[date1 earlierDate:date2]]){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    };
    
    /*Enume*/
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            self.savedPhotosGroupName = [group valueForProperty:ALAssetsGroupPropertyName];
        }
    } failureBlock:^(NSError *error) {
        
    }];
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                      if (group) {
                                          NSString * groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                                          groupName = [groupName stringByReplacingOccurrencesOfString:@"@" withString:@""];
                                          __block NSMutableArray * imagesArray = [NSMutableArray array];
                                          [_groupNames addObject:groupName];
                                          
                                          [group setAssetsFilter:[ALAssetsFilter allAssets]];
                                          [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                              if (result) {
                                                  
                                                  id assetType = [result valueForProperty:ALAssetPropertyType];
                                                  BOOL canAdd = YES;
                                                  if ([self.delegate respondsToSelector:@selector(toolsSystemAlbumValidAsset:type:)]) {
                                                      canAdd = [self.delegate toolsSystemAlbumValidAsset:result type:assetType];
                                                  }
                                                  
                                                  if (canAdd) {
                                                      if ([assetType isEqual:ALAssetTypePhoto]) {
                                                          [_photoAssets addObject:result];
                                                          [imagesArray addObject:result];
                                                      }
                                                      else if ([assetType isEqual:ALAssetTypeVideo]){
                                                          [_videoAssets addObject:result];
                                                      }
                                                  }
                                              }
                                              else{
                                                  [_photoAlbums setValue:[imagesArray sortedArrayWithOptions:NSSortConcurrent usingComparator:comparisonBlock] forKey:groupName];
                                              }
                                          }];
                                      }
                                      else{
                                          NSArray * array = [_photoAssets sortedArrayWithOptions:NSSortConcurrent usingComparator:comparisonBlock];
                                          
                                          _photoAssets = [[NSMutableArray alloc]initWithArray:array];
                                          
                                          [self postDataLoadFinishNotification];
                                      }
                                  }
                                failureBlock:^(NSError *error) {
                                    if (error) {
                                        [[NSNotificationCenter defaultCenter]postNotificationName:DDToolsSystemAlbumFailLoad object:nil userInfo:nil];
                                    }
                                }];
}


- (void)postDataLoadFinishNotification
{
    [[NSNotificationCenter defaultCenter]postNotificationName:DDToolsSystemAlbumDidFinishLoad object:nil];
    
    if ([self.delegate respondsToSelector:@selector(toolsSystemAlbumDidFinishLoad:)]) {
        [self.delegate toolsSystemAlbumDidFinishLoad:self];
    }
}

#pragma mark - Read From Album
- (NSArray *)albums//相册名称
{
    return _groupNames;
}

- (NSInteger)imageCountInAlbumWithName:(NSString *)albumName
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    return photoAssets.count;
}

- (UIImage *)thumbnailFromAlbumWithName:(NSString *)albumName atIndex:(NSInteger)index//缩略图
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    if (!photoAssets) {
        return nil;
    }
    if (index < 0 || index >= [photoAssets count]) {
        return nil;
    }
    
    return [UIImage imageWithCGImage:[[photoAssets objectAtIndex:index]thumbnail]];
}

- (UIImage *)imageFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index//满屏图
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    if (!photoAssets) {
        return nil;
    }
    if (index < 0 || index >= [photoAssets count]) {
        return nil;
    }
    return [UIImage imageWithCGImage:[[[photoAssets objectAtIndex:index] defaultRepresentation] fullScreenImage]];
}

- (NSURL *)imageURLFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    if (!photoAssets) {
        return nil;
    }
    if (index < 0 || index >= [photoAssets count]) {
        return nil;
    }
    ALAsset *asset = [photoAssets objectAtIndex:index];
    return asset.defaultRepresentation.url;
}

- (UIImage *)originImageFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index//原图
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    if (!photoAssets) {
        return nil;
    }
    if (index < 0 || index >= [photoAssets count]) {
        return nil;
    }
    ALAssetRepresentation * defaultRep = [[photoAssets objectAtIndex:index] defaultRepresentation];
    return [UIImage imageWithCGImage:[defaultRep fullResolutionImage] scale:1.0f orientation:(UIImageOrientation)[defaultRep orientation] ];
}

- (NSDate *)imageDateFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index//原图
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    if (!photoAssets) {
        return nil;
    }
    if (index < 0 || index >= [photoAssets count]) {
        return nil;
    }
    ALAsset * asset = [photoAssets objectAtIndex:index];
    return [asset valueForProperty:ALAssetPropertyDate];
}

- (ALAsset *)photoALAssetFromAlbumName:(NSString *)albumName atIndex:(NSInteger)index
{
    NSArray * photoAssets = [_photoAlbums valueForKey:albumName];
    if (!photoAssets) {
        return nil;
    }
    if (index < 0 || index >= [photoAssets count]) {
        return nil;
    }
    ALAsset * asset = [photoAssets objectAtIndex:index];
    return asset;
}

#pragma mark - Get
- (NSInteger)photosCount {
    return [_photoAssets count];
}

- (UIImage*)photoThumbnailAtIndex:(NSInteger)Index {
    if (Index < 0 || Index >= [_photoAssets count])
        return nil;
    
    return [UIImage imageWithCGImage:[[_photoAssets objectAtIndex:Index] thumbnail]];
}

- (UIImage*)photoImageAtIndex:(NSInteger)Index {
    if (Index < 0 || Index >= [_photoAssets count])
        return nil;
    
    return [UIImage imageWithCGImage:[[[_photoAssets objectAtIndex:Index] defaultRepresentation] fullScreenImage]];
}

- (UIImage*)originPhotoImageAtIndex:(NSInteger)Index{
    if (Index < 0 || Index >= [_photoAssets count]) {
        return nil;
    }
    ALAssetRepresentation * defaultRep = [[_photoAssets objectAtIndex:Index] defaultRepresentation];
    return [UIImage imageWithCGImage:[defaultRep fullResolutionImage] scale:1.0f orientation:(UIImageOrientation)[defaultRep orientation] ];
}

- (NSURL*)photoUrlAtIndex:(NSInteger)Index {
    if (Index < 0 || Index >= [_photoAssets count])
        return nil;
    
    return [[[_photoAssets objectAtIndex:Index] defaultRepresentation] url];
}

- (UIImage*)posterImage {
    return [self photoThumbnailAtIndex:[self photosCount] - 1];
}

//videos
- (NSInteger)videosCount {
    return [_videoAssets count];
}

- (UIImage*)videoThumbnailAtIndex:(NSInteger)index {
    if (index < 0 || index >= [_videoAssets count])
        return nil;
    
    return [UIImage imageWithCGImage:[[_videoAssets objectAtIndex:index] thumbnail]];
}

- (NSString*)videoTitleAtIndex:(NSInteger)index {
    if (index < 0 || index >= [_videoAssets count])
        return nil;
    
    return [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Video", nil), (long)index];
}

- (NSURL*)videoUrlAtIndex:(NSInteger)index {
    if (index < 0 || index >= [_videoAssets count])
        return nil;
    //    ALAssetRepresentation *ast = [[_videoAssets objectAtIndex:Index] defaultRepresentation];
    
    return [[[_videoAssets objectAtIndex:index] defaultRepresentation] url];
}

- (NSTimeInterval)videoDurationAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [_videoAssets count])
        return 0.0f;
    
    return [[[_videoAssets objectAtIndex:index]valueForProperty:ALAssetPropertyDuration]doubleValue];
}

- (ALAssetRepresentation*)videoRepresentationAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [_videoAssets count])
        return nil;
    
    return [[_videoAssets objectAtIndex:index] defaultRepresentation];
}

- (ALAsset*)photoALAssetAtIndex:(NSInteger)Index
{
    if (Index < 0 || Index >= [_photoAssets count])
        return nil;
    
    return [_photoAssets objectAtIndex:Index];
}

@end
