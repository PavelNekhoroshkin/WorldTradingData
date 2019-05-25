//
//  SessionController.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadService.h"
#import "DataService.h"
@class DownloadService;

NS_ASSUME_NONNULL_BEGIN

@interface SessionService : NSObject
@property (nonatomic,strong) DownloadService *downloadController;

- (void)firstRequestStockListDowload;
- (void)secondRequestStockListDowload:(NSString *)token login:(NSString *)login password:(NSString *)password;
- (void)thirdRequestStockListDowload;
- (void)downloadStockHistory:(NSString *)symbol  key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
