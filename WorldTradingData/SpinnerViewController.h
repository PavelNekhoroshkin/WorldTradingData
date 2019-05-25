//
//  SpinnerViewController.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 06.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpinnerViewController : UIViewController
@property (nonatomic, weak) ViewController *controller;

- (void)csvFileDownloadProcess;
- (void)showDownloadProgressInBytes:(double)totalBytesWritten;
- (void)stockListWritingProcess;
- (void)stopSpinner;

@end

NS_ASSUME_NONNULL_END
