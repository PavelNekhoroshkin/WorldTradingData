//
//  ViewController.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 04.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "ViewController.h"
#import "SpinnerViewController.h"
#import "GraphViewController.h"
#import "SettingsViewController.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SpinnerViewController *spinnerViewController;
@property (nonatomic, strong) GraphViewController *graphViewController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray <NSSortDescriptor *> *sortDescriptors;
@property (nonatomic, strong) UIImage *downloadImage;
@property (nonatomic, strong) UIImage *checkImage;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
   if([self entityIsEmpty])
   {
      [self openSettingsViewController];
   }
   
   [self prepareUI];
}


- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   NSError *error = nil;
   [self.fetchedResultsController performFetch:&error];

   [self.tableView reloadData];
}


- (void)prepareUI
{
   UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height) style:UITableViewStylePlain];
   tableView.dataSource = self;
   tableView.delegate = self;
   [self.view addSubview:tableView];
   self.tableView = tableView;
  
   UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 50)];
   searchBar.delegate = self;
   searchBar.placeholder = @"stock name or symbol";
   searchBar.searchBarStyle = UISearchBarStyleDefault;
   self.navigationItem.titleView = searchBar;
   self.searchBar = searchBar;
   
   UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"options"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettingsViewController)];
   self.navigationItem.rightBarButtonItem = optionsButton;
   
}

#pragma mark - getters

/**
 Создает fetchRequest для полного списка активов. Выполняется один раз в самом начале при создании NSFetchedResultsController
 
 @return fetchRequest на основе данных строки поиска
 */
- (NSFetchRequest *)fetchRequest
{
   NSFetchRequest *fetchRequest = [StockFromList fetchRequest];
   
   // сортировка не меняется, поэто задаем ее сразу
   NSArray <NSSortDescriptor *> *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
   
   self.sortDescriptors = sortDescriptors;
   
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   [fetchRequest setFetchBatchSize:20];
   
   return fetchRequest;
}


/**
 Ленивый геттер для fetchedResultsController
 
 @return NSFetchedResultsController
 */
- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController)
   {
      return _fetchedResultsController;
   }
   
   NSFetchRequest *fetchRequest = [self fetchRequest];
   
   NSFetchedResultsController *fetchedResultsController =
   [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.dataStore.context sectionNameKeyPath:nil cacheName:nil];
   fetchedResultsController.delegate = nil;
   
   NSError *error = nil;
   
   [fetchedResultsController performFetch:&error];
   
   _fetchedResultsController = fetchedResultsController;
   
   return _fetchedResultsController;
   
}


/**
 Геттер для иконки, обозначающей необходимость загрузки данных
 
 @return иконка загрузки
 */
- (UIImage *)downloadImage
{
   if(_downloadImage)
   {
      return  _downloadImage;
   }
   
   UIImage *download = [UIImage imageNamed:@"download"];
   
   //Уменьшим иконку до размера 15x15
   CGSize itemSize = CGSizeMake(15, 15);
   UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
   CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
   [download drawInRect:imageRect];
   download = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   _downloadImage = download;
   
   return  _downloadImage;
}


/**
 Геттер для иконки, обозначающей выполненную загрузку данных
 
 @return иконка выполненной загрузки
 */
- (UIImage *)checkImage
{
   if(! _checkImage)
   {
      UIImage *check = [UIImage imageNamed:@"check"];
      
      //Уменьшим иконку до размера 15x15
      CGSize itemSize = CGSizeMake(15, 15);
      UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
      CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
      [check drawInRect:imageRect];
      check = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      
      _checkImage = check;
   }
   return  _checkImage;
}


/**
 Ленивый геттер для подготовки объектов downloadController и sessionController, которые выполняют подключение к серверу и загрузку данных.
 
 @return подготовленный DownloadController для дальнейшего вызова методов загрузки.
 */
- (DownloadService *)downloadController
{
   if(! _downloadController)
   {
      _downloadController = [[DownloadService alloc] init];
      _downloadController.dataStore = self.dataStore;
      _downloadController.controller = self;
      
      SessionService *sessionController = [[SessionService alloc] init];
      sessionController.downloadController = _downloadController;
      
      _downloadController.sessionController = sessionController;
      
   }
   return  _downloadController;
}

#pragma mark - functional methodth

/**
 Отобразить высплывающее окно с текстом ошибки
 
 @param alertText текст ошибки, отображаемый в окне
 */
- (void) showErrorAlert:(NSString *)alertText
{
   NSString *text = @"Can't download data";
   if (alertText)
   {
      text = alertText;
   }
   
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ERROR" message:text preferredStyle:UIAlertControllerStyleAlert];
   UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
      [self.navigationController popToRootViewControllerAnimated:YES];
   }];
   [alertController addAction:okAction];
   
   [self presentViewController:alertController animated:YES completion:^{}];

}


/**
 Отображение истории изменения цены актива на графике
 @param history история изменения цены актива (Relationship выбранного объекта StockFromList и StockHistoryDay  )
 */
- (void)showGraphOfHistory:(NSOrderedSet<StockHistoryDay *> *)history
{
   if(history.count > 0)
   {
      GraphViewController *graphViewController = [[GraphViewController alloc] init];
      graphViewController.controller = self;
      graphViewController.stockHistory = history;
      
      [self.navigationController pushViewController:graphViewController animated:YES];
   }
   else
   {
      [self showErrorAlert:@"There are no data in the stock history"];
   }
}


/**
 Открытие окна настроек вызывается когда нажата кнопка optionsButton
 
 */
- (void)openSettingsViewController
{
   SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
   settingsViewController.dataStore = self.dataStore;
   settingsViewController.controller = self;
   
   [self.navigationController pushViewController:settingsViewController animated:YES];
}


/**
 Проверка сразу после запуска, что список активов пустой, чтобы отобразить окно настроек, где можно выполнить загрузку
 
 @return NO - список активов не пусой, YES - список активов не загружен, нужно отобразить окно настроек SettingsViewController
 */
-(BOOL)entityIsEmpty
{
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([StockFromList class])];
   NSError *error = nil;
   NSArray *result = [self.dataStore.context executeFetchRequest:fetchRequest error:&error];
   
   if (!error)
   {
      if ([result count] > 0)
      {
         return NO;
      }
   }
   return YES;
}

#pragma mark - UISearchBarDelegate for SearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
   if (searchText.length > 0)
   {
      self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@ OR symbol CONTAINS[c] %@", searchText, searchText];
   }
   else
   {
      self.fetchedResultsController.fetchRequest.predicate = nil;
   }
   
   NSError *error = nil;
   
   if (![self.fetchedResultsController performFetch:&error])
   {
      [self showErrorAlert:@"ERROR on performFetch fetchedResultsController"];
   }
   [self.tableView reloadData];
}

// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
   return YES;
}

// return NO to not resign first responder
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
   return YES;
}

#pragma mark - UITableView Delegate/DataSource

/**
 Description
 
 @param tableView tableView description
 @return return value description
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if ([[self.fetchedResultsController sections] count] > 0) {
      id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
      return [sectionInfo numberOfObjects];
   } else
      return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   //извлечь свободную ячейку из очереди
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
   
   if (!cell)
   {
      cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
   }
   
   StockFromList *stock = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
   if (stock)
   {
      cell.textLabel.text = stock.symbol;
      cell.detailTextLabel.text = stock.name;
      
      if(stock.isHistoryDownladed)
      {
         [cell.imageView setImage:self.checkImage];
      }
      else
      {
         [cell.imageView setImage:self.downloadImage];
      }
   }
   
   return cell;
}


/**
 Метод UITableViewDelegate
 Нажатие на элемент в списке вызывает отображение графика актива, при необходимости выполняется загрузка
 
 @param tableView не используется
 @param indexPath индкс элемента, определяет для какого актива будут отображен график
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   StockFromList *stock = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
   if (stock && stock.symbol)
   {
      NSOrderedSet<StockHistoryDay *> *history = stock.stockHistory;
      
      if(stock.isHistoryDownladed)
      {
         NSLog(@"SHOW GRAPH FOR %@", stock.symbol );
         [self showGraphOfHistory:history];
      }
      else
      {
         NSLog(@"DOWNLOAD HISTORY FOR %@", stock.symbol );
         [self.downloadController downloadStockHistory:stock.symbol stock:stock];
      }
   }
}

#pragma mark - proxi for SpinnerViewController methods

/**
 Отображает окно ожидания spinnerViewController в процессе авторизации на сервере
 */
- (void)showStartAutorisationProcess
{
   SpinnerViewController *spinnerViewController = [[SpinnerViewController alloc] init];
   self.spinnerViewController = spinnerViewController;
   spinnerViewController.controller = self;
   [self.navigationController pushViewController:spinnerViewController animated:YES];
}


/**
 Отображает окно ожидания spinnerViewController в начале загрузки данных
 
 */
- (void)showCsvFileDownloadProcess
{
   [self.spinnerViewController csvFileDownloadProcess];
   
}


/**
 Отображает окно ожидания spinnerViewController с прогрессом загрузки данных
 
 @param totalBytesWritten количество загруженных байт
 */
- (void)showStockListDownloadProgress:(double)totalBytesWritten
{
   [self.spinnerViewController showDownloadProgressInBytes:totalBytesWritten];
}


/**
 Отображает окно ожидания spinnerViewController при сохранении загруженных данных
 
 */
- (void)showStockListWritingProcess
{
   [self.spinnerViewController stockListWritingProcess];
   
}


/**
 Скрывает окно ожидания spinnerViewController после окончания загрузки данных
 
 */
- (void)showStopSpinner
{
   [self.spinnerViewController stopSpinner];
}


#pragma mark - proxi for DataStore methods

/**
 Скрывает окно ожидания spinnerViewController после окончания загрузки данных
 
 */
- (void)addStockToList:(NSArray<NSString *> *)lines
{
   [self.dataStore addStockToList:lines];
}

/**
 Сохранить загруженную историю торгов в Core Data
 
 @param stockHistory NSDictionary полученный в результате парсинга загруженнных с сервера данных по истории торгов
 @param stock объект сущности c данными актива в Core Data (для дальнейшего связывания истории актива и самого актива)
 */
- (void)addStockHistory:(NSDictionary *)stockHistory stock:(StockFromList *)stock
{
   [self.dataStore addStockHistory:stockHistory stock:stock];
}

/**
 Удаляет историю для отображаемого актива, проси метода DataStore
 
 */
- (void)deleteHistory:(NSOrderedSet<StockHistoryDay *> *)stockHistory
{
   [self.dataStore deleteHistory:stockHistory];
   [self.tableView reloadData];
}

/**
 Инициирует загрузку полного списка активов с сервера. В результате вызова загружается и отображается список активов, отображаемый на главном экране в UITableView
 */
- (void)downloadStockList
{
   
   [self.downloadController downloadStockList];
   [self showStartAutorisationProcess];
}


@end
