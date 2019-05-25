//
//  DataStore.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "DataService.h"
#import "AppDelegate.h"
#import "StockFromList+CoreDataClass.h"
#import "StockFromList+CoreDataProperties.h"


@interface DataService()
@property (nonatomic,strong)  NSArray *fetchedObjects;
@property (nonatomic,strong)  NSFetchRequest *fetchRequest;
@property (nonatomic,strong)  NSDecimalNumber *closePrevious ;

@end



@implementation DataService


#pragma mark - adding

/**
 Распарсить и сохранить данные из массив строк из файла в формате CSV в Core Data в сущности StockFromList

 @param lines массив строк из файла в формате CSV
 */
- (void)addStockToList:(NSArray<NSString *> *)lines
{
    //после успешной загрузки полного списка активов с сервера перед его сохранение полностью стираются все ранее загруженные данные
    [self dropAllStockHistoryDay];
    [self dropAllStockFromList];

    int i = 0;
    for (NSString *string in lines)
    {
        NSArray<NSString *> *stockParams = [string componentsSeparatedByString:@","];

        if ([stockParams count] >= 6)
        {
            StockFromList *stock = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([StockFromList class]) inManagedObjectContext:self.context];

            stock.symbol =  [stockParams objectAtIndex:0];
            stock.name =  [stockParams objectAtIndex:1];
            stock.currency =  [stockParams objectAtIndex:2];
            stock.stockExchangeLong =  [stockParams objectAtIndex:3];
            stock.stockExchangeShort =  [stockParams objectAtIndex:4];
            stock.timezoneName =  [stockParams objectAtIndex:5];
        }
        else
        {
            //если не удалось распарсить данные актива, а также в последней записи
            NSLog(@"ERROR %@", string);
        }
        
        i++;
        //после каждой тысячи добавленных в контекст активов выпоняется сохранение контекста, в лог пишется точка для визуализации прогресса
        if (i == 1000){
            printf(".");
            i = 0;
            NSError *error = nil;
            [self.context save:&error];
        }
    }
    NSError *error = nil;
    [self.context save:&error];
    
    [self.controller showStopSpinner];
}

/**
 Распарсить и сохранить результат загрузки истории актива (NSDictionaryформированный из JSON) связав
 
 @param stockHistory NSDictionary полученный в результате парсинга загруженнных с сервера данных по истории торгов
 @param stock объект сущности c данными актива в Core Data (для дальнейшего связывания истории актива и самого актива)
 */
- (void)addStockHistory:(NSDictionary *)stockHistory stock:(StockFromList *)stock
{
    self.closePrevious = [NSDecimalNumber zero];
    
    if(!stock)
    {
        return;
    }
    
    NSDictionary *history = [stockHistory objectForKey:@"history"];
    if(!history)
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"Can't get market history for the stock" waitUntilDone:NO];
    }
    
    //после десериализации JSON даты в словаре стали неупорядочены, нужно отсортировать даты, которые являются ключами в словаре
    NSMutableArray *datesByOrder = [NSMutableArray arrayWithCapacity:history.count];
    for (NSString *stringDate in history)
    {
        NSDate *date = [self parsingDateFromString:(NSString *)stringDate];
        [datesByOrder addObject:@{@"date": date, @"stringDate":stringDate}];
    }
    
    [datesByOrder sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [((NSDate *)[obj1 objectForKey:@"date"]) compare:((NSDate *)[obj2 objectForKey:@"date"])];
    }];
    
    
    for (NSDictionary *dateByOrder in datesByOrder)
    {
        NSString *stringDate = [dateByOrder objectForKey:@"stringDate"];
        NSDate *date = [dateByOrder objectForKey:@"date"];
        
        NSDictionary *dayData = [history objectForKey:stringDate];
        
        StockHistoryDay *stockHistoryDay = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([StockHistoryDay class]) inManagedObjectContext:self.context];
        NSDecimalNumber *close = [self parsingDecimalFromString:[dayData objectForKey:@"close"]];
        int volume = [self parsingIntFromString:[dayData objectForKey:@"volume"]];
        
        self.closePrevious = close;
        
        stockHistoryDay.date = date;
        stockHistoryDay.close = close;
        stockHistoryDay.volume = volume;
        stockHistoryDay.stock = stock;
        
    }
    
    NSError *error = nil;
    
    stock.isHistoryDownladed = YES;
    
    [self.context save:&error];
    
    if (stock && stock.symbol)
        
    {
        if(stock.isHistoryDownladed)
        {
            NSLog(@"SHOW GRAPH FOR %@", stock.symbol );
            [self.controller showGraphOfHistory:stock.stockHistory];
        }
    }
}

#pragma mark - parsing data from string

/**
 Парсер строки в NSDate
 
 @param string строка для парсинга
 @return распознанное значение (или nil, если не удалось распознать)
 */
- (NSDate *)parsingDateFromString:(NSString *)string
{
    if(string)
    {
        __block NSDate *detectedDate;
        
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:nil];
        [detector enumerateMatchesInString:string options:kNilOptions range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
            
            detectedDate = result.date;
        }];
        
        
        if(detectedDate)
        {
            return detectedDate;
        }
    }
    
    return nil;
}

/**
 Парсер строки в NSDecimalNumber
 
 @param string строка для парсинга
 @return распознанное значение (или -1.0, если не удалось распознать)
 */
- (NSDecimalNumber *)parsingDecimalFromString:(NSString *)string
{
    if(string && [string isKindOfClass:[NSString class]] )
    {
        
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:string];
        
        if ([number isKindOfClass:[NSDecimalNumber class]])
        {
            return number;
        }
        
    }
    
    return self.closePrevious;
}

/**
 Парсер строки в int
 
 @param string строка для парсинга
 @return распознанное значение (или -1, если не удалось распознать)
 */
- (int)parsingIntFromString:(NSString *)string
{
    if(string && [string isKindOfClass:[NSString class]] )
    {
        
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:string];
        
        if ([number isKindOfClass:[NSDecimalNumber class]])
        {
            return (int)[number integerValue];
        }
        
    }
    
    return -1;
}



#pragma mark - deleting

/**
 Удалить историю торгов просматриваемого актива
 
 @param stockHistory объект Relationship актива в StockFromList и всех записей по его истории в StockHistoryDay
 */
- (void)deleteHistory:(NSOrderedSet<StockHistoryDay *> *)stockHistory
{
    //сбросить признак загруженной истории
    ([stockHistory firstObject]).stock.isHistoryDownladed = nil;
    //удалить все записи об истории торгов актива
    for (StockHistoryDay *day in stockHistory)
    {
        [self.context deleteObject:day];
    }
    
    if ([[stockHistory lastObject] isDeleted])
    {
        [self.context save:nil];
    }
}

/**
 Удалить все данные обо всех активах из сущности StockFromList
 
 */
- (void)dropAllStockFromList
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([StockFromList class])];

    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *deleteError = nil;
    [self.context.persistentStoreCoordinator executeRequest:delete withContext:self.context error:&deleteError];
    [self.context save:&deleteError];
}


/**
 Удалить все загруженные истории изменения цены актива из сущности StockHistoryDay

 */
- (void)dropAllStockHistoryDay
{
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[StockHistoryDay fetchRequest] ];
    
    NSError *deleteError = nil;
    [self.context.persistentStoreCoordinator executeRequest:delete withContext:self.context error:&deleteError];
    [self.context save:&deleteError];
}

#pragma mark - getters

/**
 Ленивый геттер для login (нужен для авторизации сесси при загрузке полного списка активов с сервера), сохраненных в NSUserDefaults
 
 @return строка login, или nil если значение отсутствует
 */
- (NSString *)login
{
    if(! _login)
    {
        _login = [[NSUserDefaults standardUserDefaults] stringForKey:@"login"];
    }
    return _login;
}

/**
 Ленивый геттер для password (нужен для авторизации сесси при загрузке полного списка активов с сервера), сохраненных в NSUserDefaults
 
 @return строка password, или nil если значение отсутствует
 */
- (NSString *)password
{
    if(! _password)
    {
        _password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    }
    return  _password;
}

/**
 Ленивый геттер для password (нужен для авторизации сесси при загрузке полного списка активов с сервера), сохраненных в NSUserDefaults
 
 @return строка password, или nil если значение отсутствует
 */
- (NSString *)key
{
    if(! _key)
    {
        _key = [[NSUserDefaults standardUserDefaults] stringForKey:@"key"];
    }
    return  _key;
}

@end
