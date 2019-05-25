//
//  StockFromList+CoreDataProperties.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 19.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//
//

#import "StockFromList+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StockFromList (CoreDataProperties)

+ (NSFetchRequest<StockFromList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *currency;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *stockExchangeLong;
@property (nullable, nonatomic, copy) NSString *stockExchangeShort;
@property (nullable, nonatomic, copy) NSString *symbol;
@property (nullable, nonatomic, copy) NSString *timezoneName;
@property (nonatomic) BOOL isHistoryDownladed;

@property (nullable, nonatomic, retain) NSOrderedSet<StockHistoryDay *> *stockHistory;

@end

@interface StockFromList (CoreDataGeneratedAccessors)

- (void)insertObject:(StockHistoryDay *)value inStockHistoryAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStockHistoryAtIndex:(NSUInteger)idx;
- (void)insertStockHistory:(NSArray<StockHistoryDay *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStockHistoryAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStockHistoryAtIndex:(NSUInteger)idx withObject:(StockHistoryDay *)value;
- (void)replaceStockHistoryAtIndexes:(NSIndexSet *)indexes withStockHistory:(NSArray<StockHistoryDay *> *)values;
- (void)addStockHistoryObject:(StockHistoryDay *)value;
- (void)removeStockHistoryObject:(StockHistoryDay *)value;
- (void)addStockHistory:(NSOrderedSet<StockHistoryDay *> *)values;
- (void)removeStockHistory:(NSOrderedSet<StockHistoryDay *> *)values;

@end

NS_ASSUME_NONNULL_END
