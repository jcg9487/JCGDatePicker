//
//  JCGDatePickerView.m
//  JCGUIProject
//
//  Created by Edward on 2018/10/9.
//  Copyright © 2018 Edward. All rights reserved.
//

#import "JCGDatePickerView.h"

//闰年判断
#define isleap(year) ((year) % 4 == 0 && ((year) % 100 != 0 || (year) % 400 == 0))
#define kAnimationTime 0.25

@interface JCGDatePickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    
    UIView *contentView;
    UIPickerView *datePickerView;
    void(^backBlock)(id response);
    
    //数据源。
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *dayArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    NSMutableArray *secondArray;
    
    //最大值。
    NSInteger maxYear;
    NSInteger maxMonth;
    NSInteger maxDay;
    NSInteger maxHour;
    NSInteger maxMinute;
    NSInteger maxSecond;
    
    NSInteger minYear;
    
    NSDate    *minDate;
    NSDate    *maxDate;
    
    //选中行数。
    NSInteger selectedYearRow;
    NSInteger selectedMonthRow;
    NSInteger selectedDayRow;
    NSInteger selectedHourRow;
    NSInteger selectedMinuteRow;
    NSInteger selectedSecondRow;
    
    NSInteger limitYearRow;
    NSInteger limitMonthRow;
    NSInteger limitDayRow;
    NSInteger limitHourRow;
    NSInteger limitMinuteRow;
    NSInteger limitSecondRow;
}

@property (nonatomic, assign) JCGDatePickerModel pickerModel; //日期显示模式，默认为

@end

@implementation JCGDatePickerView

#pragma mark - instancetype

- (instancetype)initWithPickerModel:(JCGDatePickerModel)pickerModel MiniDate:(NSDate *)miniDate MaxDate:(NSDate *)maxmDate withResponse:(void(^)(NSDate *date))block {
    
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    
    _pickerModel = pickerModel;
    
    [self __initInterface];
    [self __initData];
    
    minDate = miniDate;
    maxDate = maxmDate;
    
    backBlock = block;
    
    return self;
}

//初始化界面
- (void)__initInterface {
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 300)];
    [self addSubview:contentView];
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 60) * i, 0, 60, 40)];
        [button setTitle:i == 0 ? @"取消" : @"确定" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 260)];
    datePickerView.delegate = self;
    datePickerView.dataSource = self;
    datePickerView.backgroundColor = [UIColor colorWithRed:240.0/255 green:243.0/255 blue:250.0/255 alpha:1];
    datePickerView.showsSelectionIndicator = YES;
    
    [contentView addSubview:datePickerView];
}

//初始化数据
- (void)__initData {
    
    minYear = 1970;
    maxYear = 2099;
    maxMonth = 12;
    maxDay = 31;
    maxHour = 23;
    maxMinute = 59;
    maxSecond = 59;
    
    //初始化当前时间。
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *currentDateComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = [currentDateComponents year];
    NSInteger currentMonth = [currentDateComponents month];
    NSInteger currentDay = [currentDateComponents day];
    NSInteger currentHour = [currentDateComponents hour];
    NSInteger currentMinute = [currentDateComponents minute];
    NSInteger currentSecond = [currentDateComponents second];
    
    if (currentMonth == 2) {
        if (isleap(currentYear)) {
            maxDay = 29;
        }
        else{
            maxDay = 28;
        }
    }
    else if (currentMonth == 1 || currentMonth == 3 || currentMonth == 5 || currentMonth == 7 ||
             currentMonth == 8 || currentMonth == 10 || currentMonth == 12){
        maxDay = 31;
    }
    else{
        maxDay = 30;
    }
    
    //初始化年份数组(范围自定义)。
    yearArray = [[NSMutableArray alloc]init];
    for (NSInteger i = minYear; i <= maxYear; i ++) {
        [yearArray addObject:[NSString stringWithFormat:@"%ld年",(long)i]];
    }
    selectedYearRow = [yearArray indexOfObject:[NSString stringWithFormat:@"%ld年",(long)currentYear]];
    limitYearRow = [yearArray indexOfObject:[NSString stringWithFormat:@"%ld年",(long)currentYear]];
    
    //初始化月份数组(1-12)。
    monthArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1; i <= maxMonth; i++) {
        [monthArray addObject:[NSString stringWithFormat:@"%ld月",(long)i]];
    }
    selectedMonthRow = currentMonth - 1;
    limitMonthRow = currentMonth - 1;
    
    //初始化天数数组(1-31)。
    dayArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1; i <= maxDay; i++) {
        [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
    }
    selectedDayRow = currentDay - 1;
    limitDayRow = currentDay - 1;
    
    //初始化小时数组(0-23)。
    hourArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i <= maxHour; i++) {
        [hourArray addObject:[NSString stringWithFormat:@"%ld时",(long)i]];
    }
    selectedHourRow = currentHour;
    limitHourRow = currentHour;
    
    //初始化分钟数组(0-59)。
    minuteArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i <= maxMinute; i++) {
        [minuteArray addObject:[NSString stringWithFormat:@"%ld分",(long)i]];
    }
    selectedMinuteRow = currentMinute;
    limitMinuteRow = currentMinute;
    
    //初始化秒数组(0-59)。
    secondArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i <= maxSecond; i++) {
        [secondArray addObject:[NSString stringWithFormat:@"%ld秒",(long)i]];
    }
    selectedSecondRow = currentSecond;
    limitSecondRow = currentSecond;
    
    switch (_pickerModel) {
        case PickerModelYear:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            break;
        case PickerModelYearMonth:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMonthRow inComponent:1 animated:YES];
            break;
        case PickerModelYearMonthDay:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMonthRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
            break;
        case PickerModelYearMonthDayHour:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMonthRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:3 animated:YES];
            break;
        case PickerModelYearMonthDayHourMinute:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMonthRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:3 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:4 animated:YES];
            break;
        case PickerModelYearMonthDayHourMinuteSeconds:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMonthRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:3 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:4 animated:YES];
            [datePickerView selectRow:selectedSecondRow inComponent:5 animated:YES];
            break;
        case PickerModelMonth:
            [datePickerView selectRow:selectedMonthRow inComponent:0 animated:YES];
            break;
        case PickerModelMonthDay:
            [datePickerView selectRow:selectedMonthRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:1 animated:YES];
            break;
        case PickerModelMonthDayHour:
            [datePickerView selectRow:selectedMonthRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:2 animated:YES];
            break;
        case PickerModelMonthDayHourMinute:
            [datePickerView selectRow:selectedMonthRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:3 animated:YES];
            break;
        case PickerModelMonthDayHourMinuteSeconds:
            [datePickerView selectRow:selectedMonthRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:3 animated:YES];
            [datePickerView selectRow:selectedSecondRow inComponent:4 animated:YES];
            break;
        case PickerModelDay:
            [datePickerView selectRow:selectedDayRow inComponent:0 animated:YES];
            break;
        case PickerModelDayHour:
            [datePickerView selectRow:selectedDayRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:1 animated:YES];
            break;
        case PickerModelDayHourMinute:
            [datePickerView selectRow:selectedDayRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:1 animated:YES];
            break;
        case PickerModelDayHourMinuteSeconds:
            [datePickerView selectRow:selectedDayRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedSecondRow inComponent:3 animated:YES];
            break;
        case PickerModelHour:
            [datePickerView selectRow:selectedHourRow inComponent:0 animated:YES];
            break;
        case PickerModelHourMinute:
            [datePickerView selectRow:selectedHourRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:1 animated:YES];
            break;
        case PickerModelHourMinuteSeconds:
            [datePickerView selectRow:selectedHourRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedSecondRow inComponent:2 animated:YES];
            break;
        case PickerModelMinute:
            [datePickerView selectRow:selectedMinuteRow inComponent:0 animated:YES];
            break;
        case PickerModelMinuteSeconds:
            [datePickerView selectRow:selectedMinuteRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedSecondRow inComponent:1 animated:YES];
            break;
        case PickerModelSeconds:
            [datePickerView selectRow:selectedSecondRow inComponent:0 animated:YES];
            break;
        default:
            [datePickerView selectRow:selectedYearRow inComponent:0 animated:YES];
            [datePickerView selectRow:selectedMonthRow inComponent:1 animated:YES];
            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
            [datePickerView selectRow:selectedHourRow inComponent:3 animated:YES];
            [datePickerView selectRow:selectedMinuteRow inComponent:4 animated:YES];
            [datePickerView selectRow:selectedSecondRow inComponent:5 animated:YES];
            break;
    }
    
}

- (NSDate *)selectedDateWith:(NSDateComponents *)dateComponents {
    
    //当前时间
    NSCalendar *currentCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *currentDateComponents = [currentCalendar components:calendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = [currentDateComponents year];
    NSInteger currentMonth = [currentDateComponents month];
    NSInteger currentDay = [currentDateComponents day];
    NSInteger currentHour = [currentDateComponents hour];
    NSInteger currentMinute = [currentDateComponents minute];
    
    switch (_pickerModel) {
            
        case PickerModelYear:
        {
            [dateComponents setYear:[[yearArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
        }
            break;
        case PickerModelYearMonth:
        {
            [dateComponents setYear:[[yearArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
        }
            break;
        case PickerModelYearMonthDay:
        {
            [dateComponents setYear:[[yearArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
        }
            break;
        case PickerModelYearMonthDayHour:
        {
            [dateComponents setYear:[[yearArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:3]] integerValue]];
        }
            break;
        case PickerModelYearMonthDayHourMinute:
        {
            [dateComponents setYear:[[yearArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:3]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:4]] integerValue]];
        }
            break;
        case PickerModelYearMonthDayHourMinuteSeconds:
        {
            [dateComponents setYear:[[yearArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:3]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:4]] integerValue]];
            [dateComponents setSecond:[[secondArray objectAtIndex:[datePickerView selectedRowInComponent:5]] integerValue]];
        }
            break;
        case PickerModelMonth:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
        }
            break;
        case PickerModelMonthDay:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
        }
            break;
        case PickerModelMonthDayHour:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
        }
            break;
        case PickerModelMonthDayHourMinute:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:3]] integerValue]];
        }
            break;
        case PickerModelMonthDayHourMinuteSeconds:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:[[monthArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:3]] integerValue]];
            [dateComponents setSecond:[[secondArray objectAtIndex:[datePickerView selectedRowInComponent:4]] integerValue]];
        }
            break;
            
        case PickerModelDay:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
        }
            break;
        case PickerModelDayHour:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
        }
            break;
        case PickerModelDayHourMinute:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
        }
            break;
        case PickerModelDayHourMinuteSeconds:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:[[dayArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
            [dateComponents setSecond:[[secondArray objectAtIndex:[datePickerView selectedRowInComponent:3]] integerValue]];
        }
            break;
            
        case PickerModelHour:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:currentDay];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
        }
            break;
        case PickerModelHourMinute:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:currentDay];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
        }
            break;
        case PickerModelHourMinuteSeconds:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:currentDay];
            [dateComponents setHour:[[hourArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
            [dateComponents setSecond:[[secondArray objectAtIndex:[datePickerView selectedRowInComponent:2]] integerValue]];
        }
            break;
            
        case PickerModelMinute:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:currentDay];
            [dateComponents setHour:currentHour];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
        }
            break;
        case PickerModelMinuteSeconds:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:currentDay];
            [dateComponents setHour:currentHour];
            [dateComponents setMinute:[[minuteArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
            [dateComponents setSecond:[[secondArray objectAtIndex:[datePickerView selectedRowInComponent:1]] integerValue]];
        }
            break;
            
        case PickerModelSeconds:
        {
            [dateComponents setYear:currentYear];
            [dateComponents setMonth:currentMonth];
            [dateComponents setDay:currentDay];
            [dateComponents setHour:currentHour];
            [dateComponents setMinute:currentMinute];
            [dateComponents setSecond:[[secondArray objectAtIndex:[datePickerView selectedRowInComponent:0]] integerValue]];
        }
            break;
            
        default:
            break;
    }
    
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *selectedDate = [calendar dateFromComponents:dateComponents];
    
    return selectedDate;
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    
    if (sender.tag == 10) {
        
        [self dismiss];
        
    } else {
        
        if (backBlock) {
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            NSDate *selectedDate = [self selectedDateWith:dateComponents];
            backBlock(selectedDate);
        }
        
        [self dismiss];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

#pragma mark - pickerView出现
- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:kAnimationTime animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y - contentView.frame.size.height);
    }];
}
#pragma mark - pickerView消失
- (void)dismiss {
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        contentView.center = CGPointMake(self.frame.size.width/2, contentView.center.y + contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    switch (_pickerModel) {
            
        case PickerModelYear:
        case PickerModelMonth:
        case PickerModelDay:
        case PickerModelHour:
        case PickerModelMinute:
        case PickerModelSeconds:
            return 1;
            break;
            
        case PickerModelYearMonth:
        case PickerModelMonthDay:
        case PickerModelDayHour:
        case PickerModelHourMinute:
        case PickerModelMinuteSeconds:
            return 2;
            break;
            
        case PickerModelYearMonthDay:
        case PickerModelMonthDayHour:
        case PickerModelDayHourMinute:
        case PickerModelHourMinuteSeconds:
            return 3;
            break;
            
        case PickerModelYearMonthDayHour:
        case PickerModelMonthDayHourMinute:
        case PickerModelDayHourMinuteSeconds:
            return 4;
            break;
            
        case PickerModelYearMonthDayHourMinute:
        case PickerModelMonthDayHourMinuteSeconds:
            return 5;
            break;
            
        case PickerModelYearMonthDayHourMinuteSeconds:
            return 6;
            break;
            
        default:
            return 6;
            break;
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (component) {
            
        case 0:
        {
            switch (_pickerModel) {

                case PickerModelYear:
                case PickerModelYearMonth:
                case PickerModelYearMonthDay:
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    return yearArray.count;
                    break;
        
                case PickerModelMonth:
                case PickerModelMonthDay:
                case PickerModelMonthDayHour:
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    return monthArray.count;
                    break;
                    
                case PickerModelDay:
                case PickerModelDayHour:
                case PickerModelDayHourMinute:
                case PickerModelDayHourMinuteSeconds:
                    return dayArray.count;
                    break;
                   
                case PickerModelHour:
                case PickerModelHourMinute:
                case PickerModelHourMinuteSeconds:
                    return hourArray.count;
                    break;
                   
                case PickerModelMinute:
                case PickerModelMinuteSeconds:
                    return minuteArray.count;
                    break;
                    
                case PickerModelSeconds:
                    return secondArray.count;
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonth:
                case PickerModelYearMonthDay:
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    return monthArray.count;
                    break;
                    
                case PickerModelMonthDay:
                case PickerModelMonthDayHour:
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    return dayArray.count;
                    break;
                    
                case PickerModelDayHour:
                case PickerModelDayHourMinute:
                case PickerModelDayHourMinuteSeconds:
                    return hourArray.count;
                    break;
                    
                case PickerModelHourMinute:
                case PickerModelHourMinuteSeconds:
                    return minuteArray.count;
                    break;
                    
                case PickerModelMinuteSeconds:
                    return secondArray.count;
                    break;
                    
                default:
                    return 0;
                    break;
            }
        }
            break;
        case 2:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDay:
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    return dayArray.count;
                    break;
                    
                case PickerModelMonthDayHour:
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    return hourArray.count;
                    break;
                    
                case PickerModelDayHourMinute:
                case PickerModelDayHourMinuteSeconds:
                    return minuteArray.count;
                    break;
                    
                case PickerModelHourMinuteSeconds:
                    return secondArray.count;
                    break;
                    
                default:
                    return 0;
                    break;
            }
        }
            break;
        case 3:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    return hourArray.count;
                    break;
                    
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    return minuteArray.count;
                    break;
                    
                case PickerModelDayHourMinuteSeconds:
                    return secondArray.count;
                    break;
                    
                default:
                    return 0;
                    break;
            }
        }
            break;
        case 4:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    return minuteArray.count;
                    break;
                    
                case PickerModelMonthDayHourMinuteSeconds:
                    return secondArray.count;
                    break;
                    
                default:
                    return 0;
                    break;
            }
            
        }
            break;
        case 5:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHourMinuteSeconds:
                    return secondArray.count;
                    break;
                    
                default:
                    return 0;
                    break;
            }
        }
            break;
            
        default:
            return 0;
            break;
    }
    
    return 0;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        CGFloat labelWidth = 0.0;
        
        switch (_pickerModel) {
            case PickerModelYear:
            case PickerModelMonth:
            case PickerModelDay:
            case PickerModelHour:
            case PickerModelMinute:
            case PickerModelSeconds:
                labelWidth = 70;
                break;
            case PickerModelYearMonth:
            case PickerModelMonthDay:
            case PickerModelDayHour:
            case PickerModelHourMinute:
            case PickerModelMinuteSeconds:
                labelWidth = CGRectGetWidth(pickerView.frame) / 2;
                break;
            case PickerModelYearMonthDay:
            case PickerModelMonthDayHour:
            case PickerModelDayHourMinute:
            case PickerModelHourMinuteSeconds:
                labelWidth = CGRectGetWidth(pickerView.frame) / 3;
                break;
            case PickerModelYearMonthDayHour:
            case PickerModelMonthDayHourMinute:
            case PickerModelDayHourMinuteSeconds:
                labelWidth = CGRectGetWidth(pickerView.frame) / 4;
                break;
            case PickerModelYearMonthDayHourMinute:
            case PickerModelMonthDayHourMinuteSeconds:
                labelWidth = CGRectGetWidth(pickerView.frame) / 5;
                break;
            case PickerModelYearMonthDayHourMinuteSeconds:
                labelWidth = CGRectGetWidth(pickerView.frame) / 6;
                break;
     
            default:
                labelWidth = CGRectGetWidth(pickerView.frame) / 6;
                break;
        }
        
        pickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, labelWidth, 30.0f)];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    
    switch (component) {
            
        case 0:
        {
            switch (_pickerModel) {
                    
                case PickerModelYear:
                case PickerModelYearMonth:
                case PickerModelYearMonthDay:
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    pickerLabel.text = [yearArray objectAtIndex:row];
                    break;
                    
                case PickerModelMonth:
                case PickerModelMonthDay:
                case PickerModelMonthDayHour:
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    pickerLabel.text = [monthArray objectAtIndex:row];
                    break;
                    
                case PickerModelDay:
                case PickerModelDayHour:
                case PickerModelDayHourMinute:
                case PickerModelDayHourMinuteSeconds:
                    pickerLabel.text = [dayArray objectAtIndex:row];
                    break;
                    
                case PickerModelHour:
                case PickerModelHourMinute:
                case PickerModelHourMinuteSeconds:
                    pickerLabel.text = [hourArray objectAtIndex:row];
                    break;
                    
                case PickerModelMinute:
                case PickerModelMinuteSeconds:
                    pickerLabel.text = [minuteArray objectAtIndex:row];
                    break;
                    
                case PickerModelSeconds:
                    pickerLabel.text = [secondArray objectAtIndex:row];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonth:
                case PickerModelYearMonthDay:
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    pickerLabel.text = [monthArray objectAtIndex:row];
                    break;
                    
                case PickerModelMonthDay:
                case PickerModelMonthDayHour:
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    pickerLabel.text = [dayArray objectAtIndex:row];
                    break;
                    
                case PickerModelDayHour:
                case PickerModelDayHourMinute:
                case PickerModelDayHourMinuteSeconds:
                    pickerLabel.text = [hourArray objectAtIndex:row];
                    break;
                    
                case PickerModelHourMinute:
                case PickerModelHourMinuteSeconds:
                    pickerLabel.text = [minuteArray objectAtIndex:row];
                    break;
                    
                case PickerModelMinuteSeconds:
                    pickerLabel.text = [secondArray objectAtIndex:row];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDay:
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    pickerLabel.text = [dayArray objectAtIndex:row];
                    break;
                    
                case PickerModelMonthDayHour:
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    pickerLabel.text = [hourArray objectAtIndex:row];
                    break;
                    
                case PickerModelDayHourMinute:
                case PickerModelDayHourMinuteSeconds:
                    pickerLabel.text = [minuteArray objectAtIndex:row];
                    break;
                    
                case PickerModelHourMinuteSeconds:
                    pickerLabel.text = [secondArray objectAtIndex:row];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHour:
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    pickerLabel.text = [hourArray objectAtIndex:row];
                    break;
                    
                case PickerModelMonthDayHourMinute:
                case PickerModelMonthDayHourMinuteSeconds:
                    pickerLabel.text = [minuteArray objectAtIndex:row];
                    break;
                    
                case PickerModelDayHourMinuteSeconds:
                    pickerLabel.text = [secondArray objectAtIndex:row];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 4:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHourMinute:
                case PickerModelYearMonthDayHourMinuteSeconds:
                    pickerLabel.text = [minuteArray objectAtIndex:row];
                    break;
                    
                case PickerModelMonthDayHourMinuteSeconds:
                    pickerLabel.text = [secondArray objectAtIndex:row];
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case 5:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHourMinuteSeconds:
                    pickerLabel.text = [secondArray objectAtIndex:row];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return pickerLabel;
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    
    NSDate *selectedDate = [self selectedDateWith:dateComponents];
    
    NSString *maxDateStr = [self dateToStringWith:maxDate Formatter:@"yyyyMMddHHmmss"];
    NSString *minDateStr = [self dateToStringWith:minDate Formatter:@"yyyyMMddHHmmss"];
    NSString *selectedDateStr = [self dateToStringWith:selectedDate Formatter:@"yyyyMMddHHmmss"];
    
    switch (component) {
            
        case 0:
        {
            switch (_pickerModel) {
                    
                case PickerModelYear:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    selectedYearRow = row;

                }
                    break;
                case PickerModelYearMonth:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    selectedYearRow = row;

                }
                    break;
                case PickerModelYearMonthDay:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;

                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelYearMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelYearMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+4 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+4 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelYearMonthDayHourMinuteSeconds:
                {
                    
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+4 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+5 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitYearRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMonthRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+4 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+5 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];

                    if (count >= 3) {
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                    
                }
                    break;
                case PickerModelMonth:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            return;
                        }
                    }
                }
                    break;
                case PickerModelMonthDay:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 2) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:1];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 2) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:1];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    selectedYearRow = row;

                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 2) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:1];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+4 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+4 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];

                    if (count >= 2) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:1];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelDay:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;

                }
                    break;
                case PickerModelDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;

                }
                case PickerModelDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;
                }
                    break;
                case PickerModelDayHourMinuteSeconds:
                {
                   
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;
                }
                    break;
                case PickerModelHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    selectedHourRow = row;

                }
                    break;
                case PickerModelHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                    
                }
                    break;
                case PickerModelHourMinuteSeconds:
                {
                    
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelMinuteSeconds:
                {
                  
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedSecondRow = row;
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonth:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                }
                    break;
                case PickerModelYearMonthDay:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelYearMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelYearMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                }
                    break;
                case PickerModelYearMonthDayHourMinuteSeconds:
                {
                    
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+4 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMonthRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitDayRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+3 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+4 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                    NSInteger count = [self numberOfComponentsInPickerView:datePickerView];
                    
                    if (count >= 3) {
                        
                        //日边界
                        if (selectedMonthRow == 1) {
                            //2月
                            if (isleap(dateComponents.year)) {
                                maxDay = 29;
                            }
                            else{
                                maxDay = 28;
                            }
                        }
                        else if (selectedMonthRow == 0 || selectedMonthRow == 2 || selectedMonthRow == 4 || selectedMonthRow == 6 ||
                                 selectedMonthRow == 7 || selectedMonthRow == 9 || selectedMonthRow == 11){
                            maxDay = 31;
                        }
                        else{
                            maxDay = 30;
                        }
                        
                        [dayArray removeAllObjects];
                        for (NSInteger i = 1; i <= maxDay; i++) {
                            [dayArray addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
                        }
                        
                        [pickerView reloadComponent:2];
                        
                        if (selectedDayRow >= dayArray.count) {
                            //超过边界
                            selectedDayRow = dayArray.count-1;
                            [datePickerView selectRow:selectedDayRow inComponent:2 animated:YES];
                        }
                    }
                   
                }
                    break;
                case PickerModelMonthDay:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                }
                    break;
                case PickerModelMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                }
                    break;
                case PickerModelMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                }
                    break;
                case PickerModelMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMonthRow = row;
                    
                }
                    break;
                case PickerModelDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelMinuteSeconds:
                {
            
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {

                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedSecondRow = row;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDay:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;
                }
                    break;
                case PickerModelYearMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;
                }
                    break;
                case PickerModelYearMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;
                }
                    break;
                case PickerModelYearMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitDayRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitHourRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+2 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+3 animated:YES];
                            return;
                        }
                    }
                    
                    selectedDayRow = row;
                }
                    break;
                case PickerModelMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelMonthDayHourMinuteSeconds:
                {
                
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedSecondRow = row;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHour:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelYearMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                case PickerModelYearMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitHourRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitMinuteRow inComponent:component+1 animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+2 animated:YES];
                            return;
                        }
                    }
                    
                    selectedHourRow = row;
                }
                    break;
                case PickerModelMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedSecondRow = row;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 4:
        {
            switch (_pickerModel) {
                case PickerModelYearMonthDayHourMinute:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelYearMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitMinuteRow inComponent:component animated:YES];
                            [datePickerView selectRow:limitSecondRow inComponent:component+1 animated:YES];
                            return;
                        }
                    }
                    
                    selectedMinuteRow = row;
                }
                    break;
                case PickerModelMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedSecondRow = row;
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 5:
        {
            switch (_pickerModel) {
                    
                case PickerModelYearMonthDayHourMinuteSeconds:
                {
                    if (minDate) {
                        if ([selectedDateStr compare:minDateStr] < NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    if (maxDate) {
                        if ([selectedDateStr compare:maxDateStr] > NSOrderedSame) {
                            [datePickerView selectRow:limitSecondRow inComponent:component animated:YES];
                            return;
                        }
                    }
                    
                    selectedSecondRow = row;
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (NSString *)dateToStringWith:(NSDate *)date Formatter:(NSString *)fmt{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fmt];
    return [formatter stringFromDate:date];

}

@end
