//
//  ViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/26.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "ViewController.h"
#import "HomeCollectionViewCell.h"

@interface ViewController ()

@end

@implementation ViewController{
    UICollectionView *_collectionView;
    UIImageView *_logoView;
    UIButton *_takePhotoBtn;
    UIButton *_settingBtn;
    NSArray *_homePageContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *homePageFilePath = [[NSBundle mainBundle] pathForResource:@"homePage" ofType:@"plist"];
    _homePageContent = [NSArray arrayWithContentsOfFile:homePageFilePath];
    
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [self.contentView addSubview:_logoView];
    CGRect logoTemp = _logoView.frame;
    logoTemp.origin.x = (self.contentView.bounds.size.width - logoTemp.size.width)/2;
    _logoView.frame = logoTemp;
    
    _takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 60, 60, 60)];
    [_takePhotoBtn setImage:[UIImage imageNamed:@"takephoto"] forState:UIControlStateNormal];
    [_takePhotoBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTakePhoto:)]];
    [_takePhotoBtn setUserInteractionEnabled:YES];
    [self.contentView addSubview:_takePhotoBtn];
    
    _settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 60, self.contentView.bounds.size.height - 60, 60, 60)];
    [_settingBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [_settingBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSetting:)]];
    [_settingBtn setUserInteractionEnabled:YES];
    [self.contentView addSubview:_settingBtn];
    
    CGRect collectionRect = CGRectMake(15, logoTemp.size.height, self.contentView.bounds.size.width - 30, self.contentView.frame.size.height - _logoView.bounds.size.height - _settingBtn.bounds.size.height);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    // 设置item的行间距和列间距
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;

    // 设置item的大小
    CGFloat itemW = collectionRect.size.width;
    CGFloat itemH = itemW/1039*754;
    layout.itemSize = CGSizeMake(itemW, itemH);
    
    // 设置分区的头视图和尾视图 是否始终固定在屏幕上边和下边
    layout.sectionFootersPinToVisibleBounds = YES;

    // 设置滚动条方向
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:collectionRect collectionViewLayout:layout];
    [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"HomeCollectionViewCell"];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.contentView addSubview:_collectionView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self selectItemWithData:[_homePageContent objectAtIndex:indexPath.row]];
}

- (void)selectItemWithData:(NSDictionary *)data{
    NSString *type = [data objectForKey:@"type"];
    if ([@"subscriber" isEqualToString:type]) {
        
    }else if ([@"purchase" isEqualToString:type]){
        
    }else if ([@"recommend" isEqualToString:type]){
        
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_homePageContent count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionViewCell" forIndexPath:indexPath];
    [cell setContentWithData:[_homePageContent objectAtIndex:indexPath.row]];
    return cell;
}

- (void)onTakePhoto:(id)sender{
    
}

- (void)onSetting:(id)sender{
    
}

- (void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    CGRect takePhotoTemp = _takePhotoBtn.frame;
    takePhotoTemp.origin.y = self.contentView.bounds.size.height - 60;
    _takePhotoBtn.frame = takePhotoTemp;
    
    CGRect settingTemp = _settingBtn.frame;
    settingTemp.origin.y = self.contentView.bounds.size.height - 60;
    _settingBtn.frame = settingTemp;
    
    CGRect collectionTemp = _collectionView.frame;
    collectionTemp.size.height = self.contentView.frame.size.height - _logoView.bounds.size.height - _settingBtn.bounds.size.height;
    _collectionView.frame = collectionTemp;
}


@end
