//
//  ViewController.m
//  年月日选择
//
//  Created by 楼某人 on 2018/2/11.
//  Copyright © 2018年 楼某人. All rights reserved.
//

#import "ViewController.h"

#import <Masonry.h>

#define G_SCREEN_WIDTH               ([UIScreen mainScreen].bounds.size.width)
#define G_SCREEN_HEIGHT              ([UIScreen mainScreen].bounds.size.height)
#define G_SCREEN_WIDTHSCALE          G_SCREEN_WIDTH/750   //屏幕宽的750分之1
// iPhoneX 适配
#define SafeAreaTopHeight           (G_SCREEN_HEIGHT == 812.0 ? 88 : 64)
#define SafeAreaBottomHeight        (G_SCREEN_HEIGHT == 812.0 ? 82 : 48)
#define SafeAreaToBottomHeight       (G_SCREEN_HEIGHT == 812.0 ? 34 : 0)

@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
// 上部视图
@property (nonatomic, strong) UIView *viewTop;
// 取消按钮
@property (nonatomic, strong) UIButton *btnBack;
// 完成按钮
@property (nonatomic, strong) UIButton *btnComplete;
// 选择
@property (nonatomic, strong) UIPickerView *pickerView;
// 数组 分别保存年月日数据
@property (nonatomic, strong) NSMutableArray *marrYear;

@property (nonatomic, strong) NSMutableArray *marrMonth;

@property (nonatomic, strong) NSMutableArray *marrDay;
// 选中的当前行 第几行
@property (nonatomic, assign) int selectRowYear;

@property (nonatomic, assign) int selectRowMonth;

@property (nonatomic, assign) int selectRowDay;
//当前选中的列
@property (nonatomic, assign) int selectComponent;
//每个月的天数
@property (nonatomic, assign) int dayNumber;
//是否应该更新天数
@property (nonatomic, assign) Boolean dayShouldChangeEnable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initView];
}

- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    
    [self viewTop];
    
    //获取当前的年月日，并初始化
    [self getDateOfThisMonment];
    
    self.dayShouldChangeEnable = false;
}

/**
 *  根据dayNumber计算marrDay
 */
- (void)setDaysForMonth:(int)dayNumber
{
    self.marrDay = nil;
    self.marrDay = [NSMutableArray array];
    for (int i = 0; i <= dayNumber; i++)
    {
        [_marrDay addObject:[@(i) stringValue]];
    }
}

/**
 *  根据month和year计算对应的天数
 */
- (void)calculateDayWithMonth:(int)month andYear:(int)year
{
    float floatYear = [self.strYear floatValue] / 4;
    float intYear = (int)floatYear;
    
    switch (month)
    {
        case 1:  self.dayNumber = 31; break;
        case 2:
        {
            if (intYear != floatYear)
            {
                self.dayNumber = 28;
            }
            else
            {
                self.dayNumber = 29;
            }
        }
            break;
        case 3:  self.dayNumber = 31; break;
        case 4:  self.dayNumber = 30; break;
        case 5:  self.dayNumber = 31; break;
        case 6:  self.dayNumber = 30; break;
        case 7:  self.dayNumber = 31; break;
        case 8:  self.dayNumber = 31; break;
        case 9:  self.dayNumber = 30; break;
        case 10: self.dayNumber = 31; break;
        case 11: self.dayNumber = 30; break;
            
        default: self.dayNumber = 31; break;
    }
    [self setDaysForMonth:_dayNumber];
}

/**
 *  获取当期的年月日，并且初始化pickerView及其它参数
 */
- (void)getDateOfThisMonment
{
    // 获取当前的年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger calendarUnit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    
    NSDateComponents *dateCompents = [calendar components:calendarUnit fromDate:[NSDate date]];
    
    int year =  (int)[dateCompents year];
    int month = (int)[dateCompents month];
    int day =   (int)[dateCompents day];
    
    //根据月份和年份计算天数
    [self calculateDayWithMonth:month andYear:year];
    
    self.selectRowYear = year - 2013 + 40;
    self.selectRowMonth = month - 1;
    self.selectRowDay = day - 1;
    
    [self.pickerView selectRow:_selectRowYear inComponent:0 animated:NO];
    [self.pickerView selectRow:_selectRowMonth inComponent:1 animated:NO];
    [self.pickerView selectRow:_selectRowDay inComponent:2 animated:NO];
    
    self.strYear = [NSString stringWithFormat:@"%d",year];
    self.strMonth = [NSString stringWithFormat:@"%d",month];
    self.strDay = [NSString stringWithFormat:@"%d",day];
    
}

#pragma mark - UIPickerView DataSource ----------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) //修改年份
    {
        _dayShouldChangeEnable = true;
        self.strYear = self.marrYear[row];
        self.selectRowYear = (int)row;
        [pickerView reloadComponent:0];
    }
    else if (component == 1) //修改月份
    {
        _dayShouldChangeEnable = true;
        self.strMonth = self.marrMonth[row];
        self.selectRowMonth = (int)row;
        [pickerView reloadComponent:1];
    }
    else //修改天数
    {
        self.strDay = self.marrDay[row];
        self.selectRowDay = (int)row;
        [pickerView reloadComponent:2];
    }
    
    if (_dayShouldChangeEnable)
    {
        //调用计算天数的函数
        [self calculateDayWithMonth:[self.strMonth intValue] andYear:[self.strYear intValue]];
        //由于更新时self.selectRowDay可能大于天数的最大值，重新赋值
        if (self.selectRowDay > _dayNumber - 1)
        {
            self.selectRowDay = _dayNumber - 1;
            if (self.strDay.intValue > self.selectRowDay)
            {
                self.strDay = [NSString stringWithFormat:@"%d",_dayNumber];
            }
        }
        [pickerView reloadComponent:2];
        _dayShouldChangeEnable = false;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {//年
        return self.marrYear.count;
    }
    else if (component == 1) //月
    {
        return self.marrMonth.count;
    }
    else
    {
        return self.marrDay.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%@年",[self.marrYear objectAtIndex:row]];
    }
    else if (component == 1)
    {
        return [NSString stringWithFormat:@"%@月",[self.marrMonth objectAtIndex:row]];
    }
    else
    {
        return [NSString stringWithFormat:@"%@日",[self.marrDay objectAtIndex:row]];
    }
}

#pragma mark - Lazying ----------------------

- (UIButton *)btnComplete
{
    if (!_btnComplete)
    {
        _btnComplete = [[UIButton alloc] init];
        _btnComplete.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btnComplete setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnComplete setTitle:@"确定" forState:UIControlStateNormal];
        
        [self.viewTop addSubview:_btnComplete];
        [_btnComplete mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.viewTop);
            make.right.mas_equalTo(self.viewTop).offset(-10 * G_SCREEN_WIDTHSCALE);
            make.width.mas_equalTo(100 * G_SCREEN_WIDTHSCALE);
        }];
    }
    return _btnComplete;
}

- (UIButton *)btnBack
{
    if (!_btnBack)
    {
        _btnBack = [UIButton new];
        [_btnBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnBack setTitle:@"取消" forState:UIControlStateNormal];
        _btnBack.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.viewTop addSubview:_btnBack];
        [_btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.viewTop);
            make.left.mas_equalTo(self.viewTop).offset(20 * G_SCREEN_WIDTHSCALE);
            make.width.mas_equalTo(100 * G_SCREEN_WIDTHSCALE);
        }];
    }
    return _btnBack;
}

- (UIView *)viewTop
{
    if (!_viewTop)
    {
        _viewTop = [UIView new];
        _viewTop.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_viewTop];
        [_viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.pickerView.mas_top);
            make.height.mas_equalTo(100 * G_SCREEN_WIDTHSCALE);
        }];
        
        [self btnBack];
        [self btnComplete];
    }
    return _viewTop;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView)
    {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        [self.view addSubview:_pickerView];
        [_pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).offset(-SafeAreaToBottomHeight);
            make.height.mas_equalTo(440 * G_SCREEN_WIDTHSCALE);
        }];
    }
    return _pickerView;
}

- (NSMutableArray *)marrYear
{
    if (!_marrYear)
    {
        _marrYear = [NSMutableArray array];
        for (int i = 1965; i < 2031; i++)
        {
            [_marrYear addObject:[@(i) stringValue]];
        }
    }
    return _marrYear;
}

- (NSMutableArray *)marrMonth
{
    if (!_marrMonth)
    {
        _marrMonth = [NSMutableArray array];
        for (int i = 1; i < 13; i++)
        {
            [_marrMonth addObject:[@(i) stringValue]];
        }
    }
    return _marrMonth;
}













- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
