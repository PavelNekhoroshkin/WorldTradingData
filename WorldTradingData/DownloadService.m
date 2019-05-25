//
//  DownloadController.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "DownloadService.h"

@interface DownloadService()
//актив, по которому загружается история тогров
@property (nonatomic,strong) id stockForDownloadHistory;
@end


@implementation DownloadService

/**
 Начать загрузке списка активов (будет последовательно выполнено три запроса: открвтие сессии, авторизация, загрузка файла через авторизованную сессию)
 */
- (void) downloadStockList
{
    [self.sessionController firstRequestStockListDowload];
}


/**
 Первый запрос выполняется для открытия сессии и получения одноразового токена. Сессию с токеном нужно будет авторизовать по логину и паролю с помощью второго запроса

 @param responce результат запроса с заголовками
 @param data тело с ответом сервера (html страница авторизации)
 */
- (void)firstRequestProceedResponce:(NSHTTPURLResponse *)responce data:(NSData *)data
{
    if ([responce statusCode] != 200)
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"Can't get session data from server" waitUntilDone:NO];
        return;
    }
    
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *tokenRegexpString = @"<meta name=\"csrf-token\" content=\"(\\w+)\">";
    NSString *token = [self getSubstringFromHTML:html regexpString:tokenRegexpString];
    
    if(!token)
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"Can't get ephemeral token from server" waitUntilDone:NO];
        return;
    }
    
    if(!(self.dataStore.login && self.dataStore.password))
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"There is no login and password saved, try to save login and password in options and download stock list" waitUntilDone:NO];
    }
    
    [self.sessionController secondRequestStockListDowload:token login:self.dataStore.login password:self.dataStore.password];
}


/**
Авторизация сессии и одноразого токена,  куки авторизованной сессии сохраняется в SessionController. Авторищованная сессия нужна для загрузки полного списка активов с сервера.

 @param responce результат запроса с заголовками
 @param data тело с ответом сервера (html страница с ключом API, ссылками и инструкциями, может быть полезен только ключ API)
 */
- (void)secondRequestProceedResponce:(NSHTTPURLResponse *)responce data:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller showCsvFileDownloadProcess];
    });
    
    if ([responce statusCode] != 200)
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:nil waitUntilDone:NO];
        return;
    }
    NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *keyRegexpString = @"<span class=\"js-copy-to-clipboard copy-code\">copy</span> <pre class=\" language-markup\"><code class=\" js-code language-markup\">(\\w+)</code>";
    NSString *key = [self getSubstringFromHTML:html regexpString:keyRegexpString];
    
    if(!key)
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"Can't get API key from server" waitUntilDone:NO];
        return;
    }
    
    self.dataStore.key = key;
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"key"];
    
    NSLog(@"%@", html);
    
    [self.sessionController thirdRequestStockListDowload];

}

/**
 Метод делегата NSURLSessionDownloadTask при згрузке полного списка активов с сервера (около 4,5 Mb), вызывается периодичести для передачи в делегат данных о прогрессе загрузки

 @param session назначенная строка-идентификатор сессии
 @param downloadTask назначенная строка-идентификатор задачи загрузки NSURLSessionDownloadTask
 @param bytesWritten количество дозагруженных байт
 @param totalBytesWritten счетчик загруженных байт
 @param totalBytesExpectedToWrite всего должно быть загружено передается, если значение было передано сервером в заготовке ответа, в данном случае сервер передает -1, что не позволяет отображать относительный  прогресс
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller showStockListDownloadProgress:(double)totalBytesWritten];
        });
    
    printf(".");
}


/**
 Метод делегата NSURLSessionDownloadTask при згрузке полного списка активов с сервера, вызывается после полной загрузки, когда все данные загружены в файл. Метод передает загруженные данные на обработку и сохранение в Core Data


 @param session назначенная строка-идентификатор сессии
 @param downloadTask назначенная строка-идентификатор задачи загрузки NSURLSessionDownloadTask
 @param location локальный URL на временный файл с загруженными данными
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if (!location)
    {
        [self.controller showStopSpinner];

        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"Can't download stock list" waitUntilDone:NO];
        
        return;
    }
    
    NSData *csvData = [NSData dataWithContentsOfURL:location];
    if(csvData){

        NSString* content = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
        //разбить загруженные данные (в формате CSV) на строки
        NSArray<NSString *> *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        //через главную очередь вызывается метод для отображения процесса в интерфейсе и метод для сохранения данных в Core Data
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.controller showStockListWritingProcess];
            [self.controller addStockToList:lines];
        });
    }
    else
    {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"ERROR DOWNLOADING STOCK LIST FROM THE SERVER" waitUntilDone:NO];
        [self.controller showStopSpinner];
        return;
    }
}


/**
 Выполнить поиск подстроки по regexp

 @param string исходная строка, в которой выполняется поиск
 @param regexpString регулярное выражение
 @return найденная подстрока или nil
 */
- (NSString *)getSubstringFromHTML:(NSString *)string regexpString:(NSString *)regexpString
{
    NSError *regexError = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexpString options:NSRegularExpressionCaseInsensitive error:&regexError];
    
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSString *substring;
    for (NSTextCheckingResult *match in matches)
    {
        NSRange group1 = [match rangeAtIndex:1];
        substring =  [string substringWithRange:group1];
    }
    
    return substring;
}


/**
 Отправка запроса для загрузки истории торгов по активу с сайта


 @param symbol кодовое обозначение актива на бирже
 @param stock объект сущности c данными актива в Core Data (для дальнейшего связывания истории актива и самого актива)
 */
- (void)downloadStockHistory:(NSString *)symbol stock:(id)stock
{
    self.stockForDownloadHistory = stock;
    if (!self.dataStore.key) {
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"There is no API key, try to put login and password in options and download stock list" waitUntilDone:NO];
        [self.controller showStopSpinner];
    }

    [self.sessionController downloadStockHistory:symbol key:self.dataStore.key];
}

/**
 Предварительная обработка ответа с историей актива и передача данных для сохранения в Core Data


 @param response ответ с заголовками
 @param data данные в формате JSON c данными по истории торгов
 */
- (void)downloadStockHistoryProceedResponce:(NSHTTPURLResponse *)response data:(NSData *)data
{
    if (!data)
    {
        [self.controller showStopSpinner];
        
        [self.controller performSelectorOnMainThread:@selector(showErrorAlert:) withObject:@"Can't download history for symbol" waitUntilDone:NO];
        return;
    }
    
    NSError *error = nil;
    NSDictionary *stockHistory = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"Downloaded history - %d records", (int) [[stockHistory objectForKey:@"history"] count]);
    
    //вызвать в главной очереди метод для сохранения истории торгов в Core Data
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller addStockHistory:stockHistory stock:self.stockForDownloadHistory];
    });
    
}


@end
