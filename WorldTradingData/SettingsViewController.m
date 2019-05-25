//
//  SettingsViewController.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 14.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "SettingsViewController.h"


@interface SettingsViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *urlComment;
@property (nonatomic, strong) UITextView *url;
@property (nonatomic, strong) UILabel *titleText;
@property (nonatomic, strong) UILabel *apiKey;
@property (nonatomic, strong) UITextField *loginTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@end



/**
 SettingsViewController
 */
@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
}


- (void)prepareUI
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel *urlComment = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width-40, 75)];
    [urlComment setText:@"If you have not registered yet, please go to the site and register your username / password on the server (E-mail confirmation is not required)"];
    urlComment.textColor = UIColor.redColor;
    [urlComment setFont:[UIFont boldSystemFontOfSize:12]];
    urlComment.textAlignment = NSTextAlignmentLeft;
    urlComment.numberOfLines = 4;
    [self.view addSubview:urlComment];
    self.urlComment = urlComment;
    
    
    UITextView *url = [[UITextView alloc] initWithFrame:CGRectMake(20, 120, self.view.frame.size.width-40, 22)];
    url.editable = NO;
    url.dataDetectorTypes = UIDataDetectorTypeAll;
    url.textColor = UIColor.grayColor;
    [url setFont:[UIFont boldSystemFontOfSize:12]];
    url.textAlignment = NSTextAlignmentLeft;
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"www.worldtradingdata.com"];
    [str addAttribute: NSLinkAttributeName value: @"https://www.worldtradingdata.com/register" range: NSMakeRange(0, str.length)];
    url.attributedText = str;
    [self.view addSubview:url];
    
    self.url = url;
    
    UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-40, 40)];
    [titleText setText:@"CREDENTIALS:"];
    titleText.textColor = UIColor.redColor;
    [titleText setFont:[UIFont boldSystemFontOfSize:28]];
    titleText.textAlignment = NSTextAlignmentLeft;
    titleText.numberOfLines = 2;
    [self.view addSubview:titleText];
    self.titleText = titleText;
    
    UITextField *loginTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleText.frame) + 5, CGRectGetWidth(self.view.frame) - 20 * 2, 50)];
    loginTextField.borderStyle = UITextBorderStyleLine;
    loginTextField.delegate = self;
    loginTextField.placeholder = @"LOGIN(E-mail)";
    [self.view addSubview:loginTextField];
    self.loginTextField = loginTextField;
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(loginTextField.frame) + 5, CGRectGetWidth(self.view.frame) - 20 *2, 50)];
    passwordTextField.delegate = self;
    passwordTextField.borderStyle = UITextBorderStyleLine;
    passwordTextField.placeholder = @"PASSWORD";
    passwordTextField.secureTextEntry = YES;

    [self.view addSubview:passwordTextField];
    self.passwordTextField = passwordTextField;
    
    if (self.dataStore.login && self.dataStore.password)
    {
        loginTextField.text = self.dataStore.login;
        passwordTextField.text = self.dataStore.password;
    }
    
    NSString *text = @"API KEY: ";
    if(self.dataStore.key)
    {
        text = [text stringByAppendingString:self.dataStore.key];
    }
    else
    {
         text = [text stringByAppendingString:@"absent API key, enter login and password and download stock list"];
    }
    
    UILabel *apiKey = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(passwordTextField.frame) + 5, self.view.frame.size.width-40, 60)];
    [apiKey setText:text];
    apiKey.textColor = UIColor.grayColor;
    [apiKey setFont:[UIFont boldSystemFontOfSize:12]];
    apiKey.textAlignment = NSTextAlignmentLeft;
    apiKey.numberOfLines = 0;
    [self.view addSubview:apiKey];
    self.apiKey = apiKey;
    
    UIButton *saveCredentialsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-200, self.view.frame.size.width-40, 40)];
    [saveCredentialsButton setTitle:@"SAVE CREDENTIALS" forState:UIControlStateNormal];
    saveCredentialsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [saveCredentialsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [saveCredentialsButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [saveCredentialsButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [saveCredentialsButton addTarget:self action:@selector(saveCredentials) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:saveCredentialsButton];
    
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-150, self.view.frame.size.width-40, 40)];
    [downloadButton setTitle:@"DOWNLOAD STOCK LIST" forState:UIControlStateNormal];
    downloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [downloadButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [downloadButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [downloadButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [downloadButton addTarget:self action:@selector(resumeFromSettings) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:downloadButton];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-100, self.view.frame.size.width-40, 40)];
    [clearButton setTitle:@"DELETE STOCK LIST" forState:UIControlStateNormal];
    clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [clearButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [clearButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(clearAllDownloadedData) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:clearButton];
    
}

/**
 Возврат к на главный экран со списком активов
 */
- (void)resumeFromSettings
{
    [self.controller downloadStockList];
}


/**
 Сохранить учетные данные в NSUserDefaults
 */
- (void)saveCredentials
{
    self.dataStore.login = self.loginTextField.text;
    self.dataStore.password = self.passwordTextField.text;
    [[NSUserDefaults standardUserDefaults] setObject:self.loginTextField.text forKey:@"login"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"password"];
}


/**
 Очистить загруженные данные по истории активов и полный список активов, загруженный с сервера
 */
- (void)clearAllDownloadedData
{
    [self.dataStore dropAllStockHistoryDay];
    [self.dataStore dropAllStockFromList];

}

@end
