//
//  StockHistoryDay+CoreDataProperties.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 19.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//
//

#import "StockHistoryDay+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StockHistoryDay (CoreDataProperties)

+ (NSFetchRequest<StockHistoryDay *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSDecimalNumber *close;
@property (nonatomic) int32_t volume;
@property (nullable, nonatomic, retain) StockFromList *stock;

@end

NS_ASSUME_NONNULL_END
