# JCGDatePicker

![](https://img.shields.io/badge/language-Objective--C-green) 
![](https://img.shields.io/badge/support-iOS9%2B-red) 
![](https://img.shields.io/badge/cocoapods-supported-green) 
![](https://img.shields.io/cocoapods/l/JCGDatePicker) 

自定义日期选择控件


```
可选则格式
typedef NS_ENUM(NSUInteger, JCGDatePickerModel) {
    PickerModelYear = 0,
    PickerModelYearMonth,
    PickerModelYearMonthDay,
    PickerModelYearMonthDayHour,
    PickerModelYearMonthDayHourMinute,
    PickerModelYearMonthDayHourMinuteSeconds,
    PickerModelMonth,
    PickerModelMonthDay,
    PickerModelMonthDayHour,
    PickerModelMonthDayHourMinute,
    PickerModelMonthDayHourMinuteSeconds,
    PickerModelDay,
    PickerModelDayHour,
    PickerModelDayHourMinute,
    PickerModelDayHourMinuteSeconds,
    PickerModelHour,
    PickerModelHourMinute,
    PickerModelHourMinuteSeconds,
    PickerModelMinute,
    PickerModelMinuteSeconds,
    PickerModelSeconds
};
```

```
/**
 初始化方法

 @param pickerModel 显示格式
 @param miniDate 最小日期限制
 @param maxDate 最大日期限制
 @param block 返回值
 @return instancetype
 */
JCGDatePickerView *datePicker = [[JCGDatePickerView alloc] initWithPickerModel:pickerModel 
                                                                      MiniDate:nil 
                                                                       MaxDate:[NSDate date]
                                                                  withResponse:^(NSDate *date) { }];
    
[datePicker show];
```
可使用cocoaPods集成
```
pod 'JCGDatePicker'
```
