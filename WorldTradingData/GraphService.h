//
//  GraphData.h
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 25.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StockHistoryDay+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN


/**
 Вспомогательный класс для рассчета величины разброса значений, минимального и максимального значения, шага сетки на графике, размера маркировки оси Y и прочих данных, необходимых для построения графика
 */
@interface GraphService : NSObject
//минимальное значение, отображаемое на графике
@property (nonatomic, assign) double graphValueMin;
//максимальное значение, отображаемое на графике
@property (nonatomic, assign) double graphValueMax;
//диапазон значений, отображаемых на графике
@property (nonatomic, assign) double graphValueRange;
//точность округления в подписях к оси Y графика
@property (nonatomic, assign) int rank;
//длина надписи к значениям по оси Y (зависит от количества разрядов в цене)
@property (nonatomic, assign) int markLength;
//диапазон значений между метками графика по оси Y
@property (nonatomic, assign) double graphVaueStep;
//ряд значений
@property (nonatomic, strong) NSArray *values;
//набор подписей к оси Х
@property (nonatomic, strong) NSArray *dates;
//frame графика
@property (nonatomic, assign) CGRect frame;
//высота области графика в поинтах
@property (nonatomic, assign) double heightY;
//шаг по оси X в поинтах
@property (nonatomic, assign) double dX;
//масштаб по Y в поинтах
@property (nonatomic, assign) double scaleY;
//отступ оси Y вправо, чтобы слева отобразить значения сетки
@property (nonatomic, assign) double indentAxisY;
//отступ оси X вверх, чтобы ниже отобразить даты
@property (nonatomic, assign) double indentAxisX;

- (void)calculateCommonDataFromHistory:(NSOrderedSet<StockHistoryDay *> *)history;
- (void)calculateScaleWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
