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
#import "EditViewController.h"
#import "SubscriberViewController.h"

@interface ViewController () <SKStoreProductViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

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
    
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kk_logo"]];
    [self.contentView addSubview:_logoView];
    CGRect logoTemp = _logoView.frame;
    logoTemp.origin.x = (self.contentView.bounds.size.width - logoTemp.size.width)/2;
    _logoView.frame = logoTemp;
    _logoView.userInteractionEnabled = YES;
    [_logoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onIap:)]];
    
    _takePhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 60, 60, 60)];
    [_takePhotoBtn setImage:[UIImage imageNamed:@"kk_takephoto"] forState:UIControlStateNormal];
    [_takePhotoBtn addTarget:self action:@selector(onTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_takePhotoBtn];
    
    _settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 60, self.contentView.bounds.size.height - 60, 60, 60)];
    [_settingBtn setImage:[UIImage imageNamed:@"kk_setting"] forState:UIControlStateNormal];
    [_settingBtn addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_settingBtn];
    
    _cameraRollBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.contentView.bounds.size.width - 100)/2 - 5, self.contentView.bounds.size.height - 60, 100, 60)];
    [_cameraRollBtn setTintColor:[UIColor whiteColor]];
    [_cameraRollBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_cameraRollBtn setTitle:@"CAMERA  ROLL" forState:UIControlStateNormal];
    [_cameraRollBtn setImage:[UIImage imageNamed:@"kk_cameraroll"] forState:UIControlStateNormal];
    [_cameraRollBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -210)];
    [_cameraRollBtn addTarget:self action:@selector(onCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_cameraRollBtn];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    // 设置item的行间距和列间距
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;

    CGRect collectionRect = CGRectMake(15, logoTemp.size.height, self.contentView.bounds.size.width - 30, self.contentView.frame.size.height - _logoView.bounds.size.height - _settingBtn.bounds.size.height);
    
    CGFloat itemW;
    if (!IS_PAD) {
        itemW = collectionRect.size.width;
    }else{
        itemW = (collectionRect.size.width - 10)/2;
    }
    UIImage *image = [UIImage imageNamed:@"kk_item"];
    CGFloat itemH = itemW/image.size.width*image.size.height;
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

-(IBAction)onIap:(id)sender{
    SubscriberViewController *subViewController = [[SubscriberViewController alloc] init];
    subViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:subViewController animated:YES];
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
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf reloadImageViewWithAsset:[assets firstObject]];
        }];
    }];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)reloadImageViewWithAsset:(PHAsset *)asset{
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeExact;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.synchronous = YES;//主要是这个设为YES这样才会只走一次
    option.networkAccessAllowed = YES;
    [manager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *resultImage, NSDictionary *info){
        UIImage *image = resultImage;
        EditViewController *editViewController = [[EditViewController alloc] init];
        [editViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [editViewController setOrignImage:image];
        [self.navigationController pushViewController:editViewController animated:YES];
    }];
}

- (IBAction)onTakePhoto:(id)sender{
#warning test
    EditViewController *editViewController = [[EditViewController alloc] init];
    [editViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [editViewController setOrignImage:[UIImage imageNamed:@"kk_lock"]];
    [self.navigationController pushViewController:editViewController animated:YES];
//    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
//    imagePicker.delegate = self;
//    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image;
    @autoreleasepool {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        EditViewController *editViewController = [[EditViewController alloc] init];
        [editViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [editViewController setOrignImage:image];
        [self.navigationController pushViewController:editViewController animated:YES];
    }];
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
