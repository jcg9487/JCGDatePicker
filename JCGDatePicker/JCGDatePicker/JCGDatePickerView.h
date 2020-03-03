//
//  JCGDatePickerView.h
//  JCGUIProject
//
//  Created by Edward on 2018/10/9.
//  Copyright © 2018 Edward. All rights reserved.
//

#import <UIKit/UIKit.h>

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


@interface JCGDatePickerView : UIView

/**
 初始化方法

 @param pickerModel 显示格式
 @param miniDate 最小日期限制
 @param maxDate 最大日期限制
 @param block 返回值
 @return instancetype
 */
- (instancetype)initWithPickerModel:(JCGDatePickerModel)pickerModel MiniDate:(NSDate *)miniDate MaxDate:(NSDate *)maxDate withResponse:(void(^)(NSDate *date))block;

- (void)show;

@end

