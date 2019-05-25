//
//  SessionController.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "SessionService.h"
#import <objc/objc.h>

@interface SessionService()
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSString *token;

@end


@implementation SessionService

- (NSURLSession *)session
{
    if(!_session)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self.downloadController delegateQueue:nil];
        _session = session;
    }
    return _session;
}


/**
 Отправить первый запрос на сервер для открытия сессии, передать ответ для обработки в DounloadService
 */
- (void) firstRequestStockListDowload
{
    NSString *urlString = @"https://www.worldtradingdata.com/login";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];

    NSURLSessionDataTask *sessionDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [self.downloadController firstRequestProceedResponce: (NSHTTPURLResponse *)response data:data];
        
    }];
    [sessionDataTask resume];
    
}


/**
 Отправить второй запрос на сервер для авторизации сессии, передать ответ для обработки в DounloadService

 @param token одноразовый токен, полученный в результате первого запроса
 @param login логин аккаунта, зарегистированного на сервере
 @param password пароль аккаунта
 */
- (void)secondRequestStockListDowload:(NSString *)token login:(NSString *)login password:(NSString *)password
{
    
    self.token = token;
    
    NSString *urlString = @"https://www.worldtradingdata.com/login";
    
    NSString *bodyString = [NSString stringWithFormat:@"_token=%@&email=%@&password=%@",token, login, password];
    NSLog(@"%@", bodyString);

    NSData *postData = [bodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setHTTPBody:postData];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:15];

    
    NSURLSessionDataTask *sessionDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        [self.downloadController secondRequestProceedResponce:(NSHTTPURLResponse *)response data:data];
        
    }];
    [sessionDataTask resume];
    
}


/**
 Отправить третий запрос на сервер для загрузки полного списка активов, делегатом задачи загрузки назначить DounloadService

 */
- (void) thirdRequestStockListDowload
{
    
   NSString *urlString = @"https://www.worldtradingdata.com/download/list";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:15];
    
    NSURLSessionDownloadTask *sessionDataTask = [self.session downloadTaskWithRequest:request];
    [sessionDataTask resume];
    
}


/**
 Направить на сервер запрос для загрузки JSON строки с данными истории торгов выбранного актива. Ответ передать для обработки в DounloadService

 @param symbol обозначение актива на бирже
 @param key ключ доступа к API
 */
- (void)downloadStockHistory:(NSString *)symbol key:(NSString *)key
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.worldtradingdata.com/api/v1/history?symbol=%@&sort=newest&api_token=%@", symbol, key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    
    NSURLSessionDataTask *sessionDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [self.downloadController downloadStockHistoryProceedResponce:(NSHTTPURLResponse *)response  data:data];
        
    }];
    
    [sessionDataTask resume];
}

@end
