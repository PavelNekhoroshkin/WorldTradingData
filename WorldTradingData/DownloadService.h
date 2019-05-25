//
//  DownloadController.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "SessionService.h"
#import "DataService.h"
@class DataService;
@class ViewController;
@class SessionService;


NS_ASSUME_NONNULL_BEGIN

@interface DownloadService : NSObject<NSURLSessionDelegate>
@property (nonatomic,weak) ViewController *controller;
@property (nonatomic,strong) SessionService *sessionController;
@property (nonatomic,weak) DataService *dataStore;

- (void) downloadStockList;
- (void)firstRequestProceedResponce:(NSHTTPURLResponse *)responce data:(NSData *)data;
- (void)secondRequestProceedResponce:(NSHTTPURLResponse *)responce data:(NSData *)data;
- (void)downloadStockHistory:(NSString *)symbol  stock:(id)stock;
- (void)downloadStockHistoryProceedResponce:(NSHTTPURLResponse *)response data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
