//
//  GraphViewController.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 18.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "DataService.h"
#import "StockHistoryDay+CoreDataClass.h"
#import "GraphService.h"


NS_ASSUME_NONNULL_BEGIN

@interface GraphViewController : UIViewController
@property (nonatomic, weak) ViewController *controller;
@property (nonatomic, weak) NSOrderedSet<StockHistoryDay *> *stockHistory;

@end

NS_ASSUME_NONNULL_END
