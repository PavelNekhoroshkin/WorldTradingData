//
//  SpinnerViewController.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 06.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "SpinnerViewController.h"

@interface SpinnerViewController ()
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UILabel *totalBytesWritte;
@end

@implementation SpinnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2 - 50, self.view.frame.size.width, 40)];
    label.textColor = UIColor.redColor;
    [label setFont:[UIFont boldSystemFontOfSize:32]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setText:@"AUTORISATION"];
    [self.view addSubview:label];
    self.label = label;
    
    UILabel *totalBytesWritte = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2 + 20, self.view.frame.size.width, 40)];
    totalBytesWritte.textColor = UIColor.redColor;
    [totalBytesWritte setFont:[UIFont boldSystemFontOfSize:32]];
    totalBytesWritte.textAlignment = NSTextAlignmentCenter;
    [totalBytesWritte setText:@""];
    [self.view addSubview:totalBytesWritte];
    self.totalBytesWritte = totalBytesWritte;
}


/**
 Закрыть окно ожидания загрузки
 */
- (void)stopSpinner
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/**
 Отобразить начало прогресса загрузки
 */
- (void)csvFileDownloadProcess
{
    [self.label setText:@"DOWNLOAD"];
}


/**
 Отобразить прогресс загрузки (количество загруженных килобайт)

 @param totalBytesWritte <#totalBytesWritte description#>
 */
- (void)showDownloadProgressInBytes:(double)totalBytesWritte
{
    [self.totalBytesWritte setText:[NSString stringWithFormat:@"%0.1f Kb", (totalBytesWritte/1024)]];

}


/**
 Отобразить процесс парсинга и сохранения загруженных данных со списком активов
 */
- (void)stockListWritingProcess
{
        [self.totalBytesWritte setText:@""];
        [self.label setText:@"WRITE"];
}

@end
