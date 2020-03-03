//
//  ViewController.m
//  JCGDatePickerView
//
//  Created by Edward on 2018/10/16.
//  Copyright © 2018 Edward. All rights reserved.
//

#import "ViewController.h"
#import "DateCellModel.h"
#import "JCGDatePicker.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *sectionTitle;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"日期选择";
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.sectionTitle = @[@"单个日期",@"多个日期"];}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
        
        NSArray *sectionOneCell = @[@{@"title":@"年",@"type":@(PickerModelYear)},
                                    @{@"title":@"月",@"type":@(PickerModelMonth)},
                                    @{@"title":@"日",@"type":@(PickerModelDay)},
                                    @{@"title":@"时",@"type":@(PickerModelHour)},
                                    @{@"title":@"分",@"type":@(PickerModelMinute)},
                                    @{@"title":@"秒",@"type":@(PickerModelSeconds)}];
        
        NSMutableArray *sectionOne = [[NSMutableArray alloc] init];
        for (NSDictionary *item in sectionOneCell) {
            
            DateCellModel *model = [[DateCellModel alloc] init];
            model.title = item[@"title"];
            model.pickerModel = [item[@"type"] integerValue];
            [sectionOne addObject:model];
        }
        
        NSArray *sectionOTwoCell = @[@{@"title":@"年月",@"type":@(PickerModelYearMonth)},
                                     @{@"title":@"年月日",@"type":@(PickerModelYearMonthDay)},
                                     @{@"title":@"年月日时",@"type":@(PickerModelYearMonthDayHour)},
                                     @{@"title":@"年月日时分",@"type":@(PickerModelYearMonthDayHourMinute)},
                                     @{@"title":@"年月日时分秒",@"type":@(PickerModelYearMonthDayHourMinuteSeconds)},
                                     @{@"title":@"月日时分秒",@"type":@(PickerModelMonthDayHourMinuteSeconds)},
                                     @{@"title":@"日时分秒",@"type":@(PickerModelDayHourMinuteSeconds)},
                                     @{@"title":@"时分秒",@"type":@(PickerModelHourMinuteSeconds)},
                                     @{@"title":@"分秒",@"type":@(PickerModelMinuteSeconds)}];
        
        NSMutableArray *sectionTwo = [[NSMutableArray alloc] init];
        for (NSDictionary *item in sectionOTwoCell) {
            
            DateCellModel *model = [[DateCellModel alloc] init];
            model.title = item[@"title"];
            model.pickerModel = [item[@"type"] integerValue];
            [sectionTwo addObject:model];
        }
        
        [_dataSource addObject:sectionOne];
        [_dataSource addObject:sectionTwo];
    }
    
    return  _dataSource;
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DateCellModel *model = self.dataSource[indexPath.section][indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.desTitle;
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block DateCellModel *model = self.dataSource[indexPath.section][indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    JCGDatePicker *datePicker = [[JCGDatePicker alloc] initWithPickerModel:model.pickerModel MiniDate:nil MaxDate:[NSDate date] withResponse:^(NSDate *date) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        switch (model.pickerModel) {
                
            case PickerModelYear:
                [formatter setDateFormat:@"yyyy年"];
                break;
            case PickerModelYearMonth:
                [formatter setDateFormat:@"yyyy年MM月"];
                break;
            case PickerModelYearMonthDay:
                [formatter setDateFormat:@"yyyy年MM月dd日"];
                break;
            case PickerModelYearMonthDayHour:
                [formatter setDateFormat:@"yyyym年MM月dd日 HH时"];
                break;
            case PickerModelYearMonthDayHourMinute:
                [formatter setDateFormat:@"yyyy年MM月dd日 HH时mm分"];
                break;
            case PickerModelYearMonthDayHourMinuteSeconds:
                [formatter setDateFormat:@"yyyy年MM月dd日 HH时mm分ss秒"];
                break;
            case PickerModelMonth:
                [formatter setDateFormat:@"MM月"];
                break;
            case PickerModelMonthDay:
                [formatter setDateFormat:@"MM月dd日"];
                break;
            case PickerModelMonthDayHour:
                [formatter setDateFormat:@"MM月dd日 HH时"];
                break;
            case PickerModelMonthDayHourMinute:
                [formatter setDateFormat:@"MM月dd日 HH时mm分"];
                break;
            case PickerModelMonthDayHourMinuteSeconds:
                [formatter setDateFormat:@"MM月dd日 HH时mm分ss秒"];
                break;
            case PickerModelDay:
                [formatter setDateFormat:@"dd日"];
                break;
            case PickerModelDayHour:
                [formatter setDateFormat:@"dd日 HH时"];
                break;
            case PickerModelDayHourMinute:
                [formatter setDateFormat:@"dd日 HH时mm分"];
                break;
            case PickerModelDayHourMinuteSeconds:
                [formatter setDateFormat:@"dd日 HH时mm分ss秒"];
                break;
            case PickerModelHour:
                [formatter setDateFormat:@"HH时"];
                break;
            case PickerModelHourMinute:
                [formatter setDateFormat:@"HH时mm分"];
                break;
            case PickerModelHourMinuteSeconds:
                [formatter setDateFormat:@"HH时mm分ss秒"];
                break;
            case PickerModelMinute:
                [formatter setDateFormat:@"mm分"];
                break;
            case PickerModelMinuteSeconds:
                [formatter setDateFormat:@"mm分ss秒"];
                break;
            case PickerModelSeconds:
                [formatter setDateFormat:@"ss秒"];
                break;
            default:
                break;
        }
        
        NSString *dateStr = [formatter stringFromDate:date];
        NSLog(@"*****%@",dateStr);
        model.desTitle = dateStr;
        
        [weakSelf.tableView reloadData];
    }];
    
    [datePicker show];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitle[section];
}


@end
