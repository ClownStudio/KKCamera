//
//  ViewController.m
//  KKCamera
//
//  Created by Jam Zhang on 2019/11/26.
//  Copyright © 2019 Jam Zhang. All rights reserved.
//

#import "ViewController.h"
#import "HomeCollectionViewCell.h"
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD+RJHUD.h"
#import "RJPhotoPicker.h"
#import "SettingViewController.h"

@interface ViewController () <SKStoreProductViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation ViewController{
    UICollectionView *_collectionView;
    UIImageView *_logoView;
    UIButton *_takePhotoBtn;
    UIButton *_settingBtn;
    UIButton *_cameraRollBtn;
    NSArray *_homePageContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *homePageFilePath = [[NSBundle mainBundle] pathForResource:@"HomePage" ofType:@"plist"];
    _homePageContent = [NSArray arrayWithContentsOfFile:homePageFilePath];
    
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [self.contentView addSubview:_logoView];
    CGRect logoTemp = _logoView.frame;
    logoTemp.origin.x = (self.contentView.bounds.size.width - logoTemp.size.width)/2;
    _logoView.frame = logoTemp;
    
    _takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 60, 60, 60)];
    [_takePhotoBtn setImage:[UIImage imageNamed:@"takephoto"] forState:UIControlStateNormal];
    [_takePhotoBtn addTarget:self action:@selector(onTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_takePhotoBtn];
    
    _settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 60, self.contentView.bounds.size.height - 60, 60, 60)];
    [_settingBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [_settingBtn addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_settingBtn];
    
    _cameraRollBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.contentView.bounds.size.width - 100)/2, self.contentView.bounds.size.height - 60, 100, 60)];
    [_cameraRollBtn setTintColor:[UIColor whiteColor]];
    [_cameraRollBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_cameraRollBtn setTitle:@"CAMERA  ROLL" forState:UIControlStateNormal];
    [_cameraRollBtn addTarget:self action:@selector(onCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_cameraRollBtn];
    
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
        [self recommendToAppStoreWithAppId:[data objectForKey:@"content"]];
    }
}

- (void)recommendToAppStoreWithAppId:(NSString *)appid {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appid forKey:SKStoreProductParameterITunesItemIdentifier];
    SKStoreProductViewController *vc = [[SKStoreProductViewController alloc] init];
    vc.delegate = self;
    [MBProgressHUD showWaitingWithText:NSLocalizedString(@"Loading", nil)];
    [vc loadProductWithParameters:dict completionBlock:^(BOOL result, NSError * _Nullable error) {
        [MBProgressHUD hide];
        if(error) {
            NSLog(@"Error：%@",error.userInfo);
        }
        else {
            [self presentViewController:vc animated:YES completion:nil];
        }
    }];
}

#pragma mark - SKStoreProductViewControllerDelegate
 
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"productViewControllerDidFinish");
    }];
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

-(IBAction)onCameraRoll:(id)sender{
    RJPhotoPicker * picker = [[RJPhotoPicker alloc] init];
    [picker.view setBackgroundColor:[UIColor blackColor]];
    [picker setLineNumber:4];
    [picker setMaxSelectedNum:1];
    [picker setModalPresentationStyle:UIModalPresentationFullScreen];
    __weak typeof(self) weakSelf = self;
    [picker setFinishBlock:^(NSArray *assets) {
        [weakSelf reloadImageViewWithAssets:assets];
    }];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)reloadImageViewWithAssets:(NSArray *)assets{
    
}

- (IBAction)onTakePhoto:(id)sender{
    
}

- (IBAction)onSetting:(id)sender{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:settingViewController animated:YES];
}

- (void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    CGRect takePhotoTemp = _takePhotoBtn.frame;
    takePhotoTemp.origin.y = self.contentView.bounds.size.height - 60;
    _takePhotoBtn.frame = takePhotoTemp;
    
    CGRect settingTemp = _settingBtn.frame;
    settingTemp.origin.y = self.contentView.bounds.size.height - 60;
    _settingBtn.frame = settingTemp;
    
    CGRect cameraRollTemp = _cameraRollBtn.frame;
    cameraRollTemp.origin.y = self.contentView.bounds.size.height - 60;
    _cameraRollBtn.frame = cameraRollTemp;
    
    CGRect collectionTemp = _collectionView.frame;
    collectionTemp.size.height = self.contentView.frame.size.height - _logoView.bounds.size.height - _settingBtn.bounds.size.height;
    _collectionView.frame = collectionTemp;
}


@end
