//
//  PCTextViewController.m
//  PhotoCollage
//
//  Created by 杜杜 on 16/4/23.
//  Copyright © 2016年 duruochuan. All rights reserved.
//

#import "PCTextViewController.h"
#import "FXLabel.h"
#import "RSColorPickerView.h"
#import "RSBrightnessSlider.h"
#import "RSColorFunctions.h"

@interface PCTextViewController ()<UITableViewDelegate,UITableViewDataSource,RSColorPickerViewDelegate> {
    BOOL _isAnimation;
    
    UITableView *_fontTableView;
    UITableView *_artFontTableView;
    UIView      *_colorPickerView;
    
    CGFloat      _keyboardHeight;
    BOOL         _isFontHidden;
    BOOL         _isColorHidden;
    BOOL         _isArtFontHidden;
    
    RSColorPickerView *_colorPicker;
    RSBrightnessSlider *_brightnessSlider;
}

@property(nonatomic,strong)NSMutableArray *fontNames;
@property(nonatomic,strong)NSArray        *artFonts;

@end

@implementation PCTextViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.artFonts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"artFonts" ofType:@"plist"]];
    self.view.alpha = 0.0f;
    _isFontHidden = _isArtFontHidden = _isColorHidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    _fontTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0, self.screenSize.height, self.screenSize.width, 300) style:UITableViewStylePlain];
    _fontTableView.backgroundColor = [UIColor colorWithHexString:kNavColor];
    _fontTableView.delegate = self;
    _fontTableView.dataSource = self;
    [self.view addSubview:_fontTableView];
    
    _artFontTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0, self.screenSize.height, self.screenSize.width, 300) style:UITableViewStylePlain];
    _artFontTableView.backgroundColor = [UIColor colorWithHexString:kNavColor];
    _artFontTableView.delegate = self;
    _artFontTableView.dataSource = self;
    [self.view addSubview:_artFontTableView];
    
    _colorPickerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.screenSize.height, self.screenSize.width, 300)];
    _colorPickerView.backgroundColor = [UIColor colorWithHexString:kNavColor];
    [self.view addSubview:_colorPickerView];
    
    self.fontNames = [NSMutableArray array];
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *familyName in familyNames) {
        [self.fontNames addObjectsFromArray:[UIFont fontNamesForFamilyName:familyName]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_textFiled becomeFirstResponder];
    });
    self.keyboardButton.selected = YES;
    self.fxLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textfieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    _fontTableView.separatorStyle = _artFontTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    self.view.frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.height);
//    self.view.backgroundColor = [UIColor clearColor];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _isAnimation = NO;
    }];
}

- (void)hidden
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _isAnimation = NO;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - KeyBoard
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect endFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    if (_keyboardHeight != endFrame.size.height) {
        _keyboardHeight = endFrame.size.height;
        [self resetAllSelectView];
    }
    CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.secondItem == self.mainView && constraint.secondAttribute == NSLayoutAttributeBottom) {
            [UIView animateWithDuration:duration animations:^{
                constraint.constant = endFrame.size.height;
            }];
        }
    }
}

#pragma mark -

- (void)resetAllSelectView
{
    _fontTableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, _keyboardHeight);
    _artFontTableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, _keyboardHeight);
    _colorPickerView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, _keyboardHeight);

    //布局colorPicker
    [_colorPicker removeFromSuperview];
    _colorPicker = [[RSColorPickerView alloc]initWithFrame:CGRectMake(15.0f, 15.0f, self.screenSize.width - 30.0f, _keyboardHeight - 60.0f)];
    [_colorPicker setSelectionColor:_label.textColor];
    [_colorPicker setDelegate:self];
    [_colorPickerView addSubview:_colorPicker];
 }

- (void)showFontView
{
    [UIView animateWithDuration:0.3f animations:^{
        _fontTableView.frame = CGRectMake(0.0f, self.screenSize.height - _keyboardHeight, self.screenSize.width, _keyboardHeight);
    }];
    _isFontHidden = NO;
}

- (void)hiddenFontView
{
    _label.hidden = NO;
    _fxLabel.hidden = YES;
    [UIView animateWithDuration:0.2f animations:^{
        _fontTableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, _keyboardHeight);
    }];
    _isFontHidden = YES;
}

- (void)showArtFontView
{
    _label.hidden = YES;
    _fxLabel.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        _artFontTableView.frame = CGRectMake(0.0f, self.screenSize.height - _keyboardHeight, self.screenSize.width, _keyboardHeight);
    }];
    _isArtFontHidden = NO;
}

- (void)hiddenArtFontView
{
    [UIView animateWithDuration:0.2f animations:^{
        _artFontTableView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, _keyboardHeight);
    }];
    _isArtFontHidden = YES;
}

- (void)showColorView
{
    _label.hidden = NO;
    _fxLabel.hidden = YES;
    [UIView animateWithDuration:0.3f animations:^{
        _colorPickerView.frame = CGRectMake(0.0f, self.screenSize.height - _keyboardHeight, self.screenSize.width, _keyboardHeight);
    }];
    _isColorHidden = NO;
}

- (void)hiddenColorView
{
    [UIView animateWithDuration:0.2f animations:^{
        _colorPickerView.frame = CGRectMake(0.0f, self.screenSize.height, self.screenSize.width, _keyboardHeight);
    }];
    _isColorHidden = YES;
}

#pragma mark - IBAction
- (void)deselectButtons
{
    self.keyboardButton.selected =
    self.fontButton.selected =
    self.artFontButton.selected =
    self.colorButton.selected = NO;
    
    if (!_isFontHidden) {
        [self hiddenFontView];
    }
    if (!_isArtFontHidden) {
        [self hiddenArtFontView];
    }
    if (!_isColorHidden) {
        [self hiddenColorView];
    }
}

- (IBAction)doneAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(textViewControllerDidDoneAction:)]) {
        [self.delegate textViewControllerDidDoneAction:self];
    }
    [self hidden];
}

- (IBAction)keyboardAction:(id)sender
{
    [self deselectButtons];
    self.keyboardButton.selected = YES;
    [self.textFiled becomeFirstResponder];
}

- (IBAction)fontAction:(id)sender
{
    [self deselectButtons];
    self.fontButton.selected = YES;
    [self.textFiled resignFirstResponder];
    [self showFontView];
}

- (IBAction)colorAction:(id)sender
{
    [self deselectButtons];
    self.colorButton.selected = YES;
    [self.textFiled resignFirstResponder];
    [self showColorView];
}

- (IBAction)artFontAction:(id)sender
{
    [self deselectButtons];
    self.artFontButton.selected = YES;
    [self.textFiled resignFirstResponder];
    [self showArtFontView];
}

- (void)configFxLabel:(FXLabel *)label WithInfo:(NSDictionary *)info
{
    CGFloat shadowBlur = [[info valueForKey:@"shadowBlur"]floatValue];
    label.shadowBlur = shadowBlur;
    
    NSString *shadowOffsetStr = [info valueForKey:@"shadowOffset"];
    if (shadowOffsetStr && shadowOffsetStr.length > 0) {
        label.shadowOffset = CGSizeFromString(shadowOffsetStr);
    }
    
    NSString *shadowColorStr = [info valueForKey:@"shadowColor"];
    if (shadowColorStr && shadowColorStr.length > 0) {
        label.shadowColor = [self colorFromString:shadowColorStr];
    }
    
    CGFloat innerShadowBlur = [[info valueForKey:@"innerShadowBlur"]floatValue];
    label.innerShadowBlur = innerShadowBlur;
    
    NSString *innerShadowOffsetStr = [info valueForKey:@"innerShadowOffset"];
    if (innerShadowOffsetStr && innerShadowOffsetStr.length > 0) {
        label.innerShadowOffset = CGSizeFromString(innerShadowOffsetStr);
    }
    
    NSString *innerShadowColorStr = [info valueForKey:@"innerShadowColor"];
    if (innerShadowColorStr && innerShadowColorStr.length > 0) {
        label.innerShadowColor = [self colorFromString:innerShadowColorStr];
    }
    
    NSString *gradientStartColorStr = [info valueForKey:@"gradientStartColor"];
    if (gradientStartColorStr && gradientStartColorStr.length > 0) {
        label.gradientStartColor = [self colorFromString:gradientStartColorStr];
    }
    
    NSString *gradientEndColorStr = [info valueForKey:@"gradientEndColor"];
    if (gradientEndColorStr && gradientEndColorStr.length > 0) {
        label.gradientEndColor = [self colorFromString:gradientEndColorStr];
    }
    
    NSString *gradientStartPointStr = [info valueForKey:@"gradientStartPoint"];
    if (gradientStartPointStr && gradientStartPointStr.length > 0) {
        label.gradientStartPoint = CGPointFromString(gradientStartPointStr);
    }
    
    NSString *gradientEndPointStr = [info valueForKey:@"gradientEndPoint"];
    if (gradientEndPointStr && gradientEndPointStr.length > 0) {
        label.gradientEndPoint = CGPointFromString(gradientEndPointStr);
    }
    
    CGFloat oversampling = [[info valueForKey:@"oversampling"]floatValue];
    label.oversampling = oversampling;
    
    CGFloat lineSpacing = [[info valueForKey:@"lineSpacing"]floatValue];
    label.lineSpacing = lineSpacing;
    
    CGFloat characterSpacing = [[info valueForKey:@"characterSpacing"]floatValue];
    label.characterSpacing = characterSpacing;
    
    CGFloat baselineOffset = [[info valueForKey:@"baselineOffset"]floatValue];
    label.baselineOffset = baselineOffset;
    
    BOOL allowOrphans = [[info valueForKey:@"allowOrphans"]boolValue];
    label.allowOrphans = allowOrphans;
    
    NSArray *gradientColors = [info valueForKey:@"gradientColors"];
    NSMutableArray *gradientColorsM = [NSMutableArray array];
    for (NSString *colorStr in gradientColors) {
        [gradientColorsM addObject:[self colorFromString:colorStr]];
    }
    label.gradientColors = gradientColorsM;
}

- (UIColor *)colorFromString:(NSString *)colorString
{
    NSArray *components = [colorString componentsSeparatedByString:@","];
    if (components.count == 4) {
        CGFloat red = [[components objectAtIndex:0]floatValue];
        CGFloat green = [[components objectAtIndex:1]floatValue];
        CGFloat blue = [[components objectAtIndex:2]floatValue];
        CGFloat alpha = [[components objectAtIndex:3]floatValue];
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    return [UIColor randomColor];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _fontTableView) {
        return self.fontNames.count;
    }
    return self.artFonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _artFontTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.backgroundColor = [UIColor clearColor];
        FXLabel *label = [[FXLabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.screenSize.width, 50.0f)];
        NSDictionary *info = [self.artFonts objectAtIndex:indexPath.row];
        label.text = [info valueForKey:@"text"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18.0];
        label.backgroundColor = [UIColor clearColor];
        [self configFxLabel:label WithInfo:info];
        [cell addSubview:label];
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.screenSize.width, 50.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self.fontNames objectAtIndex:indexPath.row];
    label.font = [UIFont fontWithName:label.text size:18.0f];
    [cell addSubview:label];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _fontTableView) {
        _label.hidden = NO;
        _fxLabel.hidden = YES;
        _label.font = [UIFont fontWithName:[self.fontNames objectAtIndex:indexPath.row] size:40.0f];
    }
    else {
        _label.hidden = YES;
        _fxLabel.hidden = NO;
        NSDictionary *info = [self.artFonts objectAtIndex:indexPath.row];
        [self configFxLabel:_fxLabel WithInfo:info];
    }
}

- (void)textfieldDidChange:(NSNotification *)notification
{
    _label.text = _textFiled.text;
    _fxLabel.text = _textFiled.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.keyboardButton.selected = YES;
    self.fontButton.selected = self.colorButton.selected = self.artFontButton.selected = NO;
}

#pragma mark - RSColorPickerViewDelegate
- (void)colorPickerDidChangeSelection:(RSColorPickerView *)colorPicker
{
    _label.hidden = NO;
    _fxLabel.hidden = YES;
    
    UIColor *color = [colorPicker selectionColor];
    _label.textColor = color;
}

@end
