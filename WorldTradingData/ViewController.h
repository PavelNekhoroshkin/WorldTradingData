//
//  ViewController.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionService.h"
#import "DownloadService.h"
#import "DataService.h"
#import "StockFromList+CoreDataClass.h"

@class DownloadService;


@interface ViewController : UIViewController
@property (nonatomic, strong) DownloadService *downloadController;
@property (nonatomic, strong) DataService *dataStore;

- (void)addStockToList:(NSArray<NSString *> *)lines;
- (void)showErrorAlert:(NSString *)alertText;
- (void)showStopSpinner;
- (void)showStartAutorisationProcess;
- (void)showCsvFileDownloadProcess;
- (void)showStockListDownloadProgress:(double)totalBytesWritten;
- (void)showStockListWritingProcess;
- (void)downloadStockList;
- (void)addStockHistory:(NSDictionary *)stockHistory stock:(StockFromList *)stock;
- (void)deleteHistory:(NSOrderedSet<StockHistoryDay *> *)stockHistory;
- (void)showGraphOfHistory:(NSOrderedSet<StockHistoryDay *> *)history;


@end

