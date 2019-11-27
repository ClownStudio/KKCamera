//
//  ViewController.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/6.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "CollageViewController.h"
#import "PCImageView.h"
#import "PCImageSelectViewController.h"
#import "PCMenuViewController.h"
#import <MessageUI/MessageUI.h>

@interface CollageViewController ()<UITableViewDataSource,UITableViewDelegate> {
    CGFloat _itemWidth;
    NSInteger _itemNumber;
    
    NSArray *_styles;
}

@end

@implementation CollageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _styles = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"stylelist" ofType:@"plist"]];
    
    CGFloat screenWidth = self.screenSize.width;
    if (self.screenSize.width > self.screenSize.height) {
        screenWidth = self.screenSize.height;
    }
    if (self.isPhone) {//左右15 24 = 3 * 8
        _itemWidth = (screenWidth - 54.0f)/4;
        _itemNumber = 4;
    }
    else {
        _itemWidth = (screenWidth - 62.0f)/5;
        _itemNumber = 5;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_styles.count/_itemNumber) + (_styles.count%_itemNumber == 0?0:1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier.cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor colorWithHexString:kBgColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[PCImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int index = 0; index < _itemNumber; index++) {
        NSInteger i = index%_itemNumber;
        NSInteger styleIndex = indexPath.row * _itemNumber + index;
        if (styleIndex >= _styles.count) {
            break;
        }
        NSString *styleFileName = [_styles objectAtIndex:styleIndex];
        CGRect frame = CGRectMake(i * (_itemWidth + 8) +15.0f, 15.0f, _itemWidth, _itemWidth);
        PCImageView *imageView = [[PCImageView alloc]initWithFrame:frame collageInfo:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:styleFileName ofType:nil]]];
        [imageView addTarget:self action:@selector(imageViewAction:) forControlEvents:UIControlEventTouchUpInside];
        imageView.tag = styleIndex;
        [cell addSubview:imageView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemWidth + 15.0f;
}

#pragma mark - ACTION
- (void)imageViewAction:(PCImageView *)sender
{
    [AppManager sharedManager].collageInfo = sender.collageInfo;
    [self performSegueWithIdentifier:@"select.image" sender:self];
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
