//
//  SettingsViewController.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 14.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "DataService.h"


NS_ASSUME_NONNULL_BEGIN

@interface SettingsViewController : UIViewController
@property (nonatomic, weak) ViewController *controller;
@property (nonatomic, weak) DataService *dataStore;

@end

NS_ASSUME_NONNULL_END
