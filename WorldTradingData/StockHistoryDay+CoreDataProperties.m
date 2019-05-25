//
//  StockHistoryDay+CoreDataProperties.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 19.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//
//

#import "StockHistoryDay+CoreDataProperties.h"

@implementation StockHistoryDay (CoreDataProperties)

+ (NSFetchRequest<StockHistoryDay *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StockHistoryDay"];
}

@dynamic date;
@dynamic close;
@dynamic volume;
@dynamic stock;

@end
