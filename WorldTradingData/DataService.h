//
//  DataStore.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "StockFromList+CoreDataClass.h"
#import "StockFromList+CoreDataProperties.h"
#import "StockHistoryDay+CoreDataClass.h"

@import CoreData;
@class ViewController;


NS_ASSUME_NONNULL_BEGIN

@interface DataService : NSObject
@property (nonatomic, strong)  NSManagedObjectContext *context;
@property (nonatomic, strong) ViewController *controller;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *key;

- (void)addStockToList:(NSArray<NSString *> *)lines;
- (void)addStockHistory:(NSDictionary *)stockHistory stock:(StockFromList *)stock;
- (void)deleteHistory:(NSOrderedSet<StockHistoryDay *> *)stockHistory;
- (void)dropAllStockHistoryDay;
- (void)dropAllStockFromList;

@end

NS_ASSUME_NONNULL_END
