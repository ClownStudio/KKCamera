//
//  PCImageSelectViewController.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/19.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCImageSelectViewController.h"
#import "DDToolsSystemAlbum.h"
#import "DDImage.h"
#import "PCSelectView.h"
#import <Photos/Photos.h>

@interface PCImageSelectViewController ()<DDToolsSystemAlbumDelegate,PCSelectViewDelegate> {
    CGFloat _itemWidth;
    NSInteger _itemNumber;
    NSInteger _maxNumber;
}

@property(nonatomic,strong)NSArray *albums;
@property(nonatomic,copy)NSString *currentAlbumName;
@property(nonatomic,strong)NSMutableArray *selectViews;
@property(nonatomic,strong)NSMutableArray *selectImages;

@end

@implementation PCImageSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (self.isPhone) {//间距为5
        _itemWidth = (screenWidth - 25.0f)/4;
        _itemNumber = 4;
    }
    else {
        _itemWidth = (screenWidth - 35.0f)/6;
        _itemNumber = 6;
    }
    
    [DDToolsSystemAlbum sharedAlbum].delegate = self;
    [[DDToolsSystemAlbum sharedAlbum]loadData]; 
    
    self.albumsTableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.albumsTableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, self.screenSize.height - 47.0f);
    
    _maxNumber = [[[AppManager sharedManager].collageInfo valueForKey:@"views"]count];
    [self updateNumberLabel];
    self.selectViews = [NSMutableArray array];
    self.selectImages = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)doneAction:(id)sender
{
    [AppManager sharedManager].selectImages = _selectImages;
    [self performSegueWithIdentifier:@"photo.collage" sender:self];
}

- (IBAction)selectAlbumAction:(id)sender
{
    [UIView animateWithDuration:0.4f animations:^{
        self.albumIconButton.transform = CGAffineTransformMakeRotation(M_PI);
        self.albumsTableView.frame = CGRectMake(0.0f, 47.0f, self.screenSize.width, self.screenSize.height - 47.0f);
    }];
}

- (void)updateAlbumButton
{
    [self.albumNameButton setTitle:self.currentAlbumName forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.albumIconButton.transform = CGAffineTransformIdentity;
        self.albumsTableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, self.screenSize.height - 47.0f);
    }];
}

- (void)updateNumberLabel
{
    if (self.selectImages.count == _maxNumber) {
        _numberLabel.text = @"MAX";
    }
    else {
        _numberLabel.text = [NSString stringWithFormat:@"%lu/%ld",(unsigned long)self.selectImages.count,(long)_maxNumber];
    }
}

- (void)imageViewTapAction:(UITapGestureRecognizer *)gesture
{
    if (self.selectImages.count == _maxNumber) {
        return;
    }
    UIImageView *imageView = (UIImageView *)gesture.view;
    if (imageView) {
        ALAsset *asset = [[DDToolsSystemAlbum sharedAlbum]photoALAssetFromAlbumName:self.currentAlbumName atIndex:imageView.tag - 1000];
        [self.selectImages addObject:[self imageWithAsset:asset size:CGSizeMake(600, 600)]];
        
        CGRect frame = CGRectMake(self.screenSize.width, 0.0f, 90.0f, 90.0f);
        PCSelectView *selectView = [[PCSelectView alloc]initWithFrame:frame image:imageView.image];
        selectView.delegate = self;
        [self.selectViews addObject:selectView];
        [self.scrollView addSubview:selectView];
        
        [self refreshSelectViews];
        [self updateNumberLabel];
    }
}

- (void)refreshSelectViews
{
    [UIView animateWithDuration:0.3f animations:^{
        for (int index = 0; index < self.selectViews.count; index++) {
            PCSelectView *view = [self.selectViews objectAtIndex:index];
            view.frame = CGRectMake(index * 90, 0, 90, 90);
        }
        self.scrollView.contentSize = CGSizeMake(self.selectViews.count * 90, 90);
    }];
}

#pragma mark - DDToolsSystemAlbumDelegate
- (void)toolsSystemAlbumDidFinishLoad:(DDToolsSystemAlbum *)systemAlbum
{
    self.albums = [[[systemAlbum albums]reverseObjectEnumerator]allObjects];
    if (self.albums.count == 0) {
        return;
    }
    self.currentAlbumName = [self.albums firstObject];
    [self updateAlbumButton];
    
    [self.albumsTableView reloadData];
    [self.photosTableView reloadData];
}

- (UIImage *)imageWithAsset:(ALAsset *)asset size:(CGSize)size
{
    if (!asset) {
        return nil;
    }
    __block UIImage *image = nil;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.synchronous = YES;
    
    PHAsset *phAsset = [[PHAsset fetchAssetsWithALAssetURLs:@[[asset valueForProperty:ALAssetPropertyAssetURL]] options:nil]firstObject];
    if (phAsset) {
        [[PHImageManager defaultManager]requestImageForAsset:phAsset targetSize:CGSizeMake(size.width, size.height) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            image = result;
//            NSLog(@"%@",[NSValue valueWithCGSize:image.size]);
        }];
    }
    return image;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _albumsTableView) {
        return self.albums.count;
    }
    NSInteger imageCount = [[DDToolsSystemAlbum sharedAlbum]imageCountInAlbumWithName:self.currentAlbumName];
    return imageCount/_itemNumber + (imageCount%_itemNumber==0?0:1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _albumsTableView) {
        static NSString *identifier = @"cell.album.identifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
            
            UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(20.0f, [self tableView:_albumsTableView heightForRowAtIndexPath:indexPath] - 0.5f, self.screenSize.width - 20.0f, 0.5f)];
            bottomView.backgroundColor = [UIColor lightGrayColor];
            [cell addSubview:bottomView];
        }
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        cell.textLabel.text = [self.albums objectAtIndex:indexPath.row];
        ALAsset *asset = [[DDToolsSystemAlbum sharedAlbum]photoALAssetFromAlbumName:[self.albums objectAtIndex:indexPath.row] atIndex:0];
        if (asset) {
            UIImage *image = [self imageWithAsset:asset size:CGSizeMake(140.0f, 140.0f)];
            cell.imageView.image = [UIImage imageWithData:UIImageJPEGRepresentation([DDImage thumbnailWithImage:image outputSize:CGSizeMake(120.0, 120.0)], 1.0f) scale:2.0];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.clipsToBounds = YES;
        }
        
        return cell;
    }
    static NSString *identifier = @"cell.select.image.identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in cell.subviews) {
        if (view.tag >= 1000) {
            [view removeFromSuperview];
        }
    }
    
    for (int index = 0; index < _itemNumber; index++) {
        ALAsset *asset = [[DDToolsSystemAlbum sharedAlbum]photoALAssetFromAlbumName:self.currentAlbumName atIndex:(indexPath.row * _itemNumber) + index];
        if (asset) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5.0f + (_itemWidth + 5.0f) * index, 5.0f, _itemWidth, _itemWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.tag = 1000 + (indexPath.row * _itemNumber) + index;
            imageView.image = [self imageWithAsset:asset size:CGSizeMake(_itemWidth * 1.5, _itemWidth * 1.5)];
            [cell addSubview:imageView];
            
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTapAction:)];
            [imageView addGestureRecognizer:tapGesture];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _albumsTableView) {
        if (self.isPhone) {
            return 70.0f;
        }
        else {
            return 100.0f;
        }
    }
    return _itemWidth + 5.0f;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _albumsTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.currentAlbumName = [self.albums objectAtIndex:indexPath.row];
        [self updateAlbumButton];
        [_photosTableView reloadData];
    }
}

#pragma mark - PCSelectViewDelegate
- (void)selectViewDidDeleteAction:(PCSelectView *)selectView
{
    if ([self.selectViews containsObject:selectView]) {
        NSInteger index = [self.selectViews indexOfObject:selectView];
        [self.selectViews removeObjectAtIndex:index];
        [self.selectImages removeObjectAtIndex:index];
        
        [selectView removeFromSuperview];
        [self refreshSelectViews];
        [self updateNumberLabel];
    }
}

@end
