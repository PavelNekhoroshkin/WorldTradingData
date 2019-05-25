//
//  StockFromList+CoreDataProperties.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 19.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//
//

#import "StockFromList+CoreDataProperties.h"

@implementation StockFromList (CoreDataProperties)

+ (NSFetchRequest<StockFromList *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"StockFromList"];
}

@dynamic currency;
@dynamic name;
@dynamic stockExchangeLong;
@dynamic stockExchangeShort;
@dynamic symbol;
@dynamic timezoneName;
@dynamic isHistoryDownladed;
@dynamic stockHistory;

@end
