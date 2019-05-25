//
//  GraphData.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 25.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "GraphService.h"

@implementation GraphService
/**
 Подготавливает на основании данных из истории ряд значений для графика, шаг сетки и масштаб
 
 @param history значения StockHistoryDay для построения графика
 */
- (void)calculateCommonDataFromHistory:(NSOrderedSet<StockHistoryDay *> *)history
{
    //переменные для вычисления минимального и максимального значения
    StockHistoryDay *firstDay = [history firstObject];
    NSDate *firstDate = firstDay.date;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:firstDate];
    
    NSInteger previouseMonth  = -1;
    NSInteger previouseYear = -1;

    double minClose = [firstDay.close doubleValue];
    double maxClose = minClose;
    
    //заполняем массив значений из полученного Set
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    
    NSInteger month;
    NSInteger year;
    
    for (StockHistoryDay *day in history)
    {
        [values addObject:day.close];
        
        double temp = [day.close doubleValue];
        if(temp < minClose)
        {
            minClose = temp;
        }
        
        if(temp > maxClose)
        {
            maxClose = temp;
        }
        
        components = [[NSCalendar currentCalendar] components: NSCalendarUnitMonth | NSCalendarUnitYear fromDate:day.date];
        
        month  = [components month];
        year = [components year];
        
        //сохраняем непустое значение только при смене месяца и года, по оси х будут выводиться только даты начала месяца
        if(month == previouseMonth && year == previouseYear)
        {
            [dates addObject:[NSNull null]];
        }
        else
        {
            if (month < 10){
                //добавить ноль в начале месяца
                [dates addObject:[NSString stringWithFormat:@"0%d.%d", (int) month, (int) year]];
            }
            else
            {
                [dates addObject:[NSString stringWithFormat:@"%d.%d", (int) month, (int) year]];

            }
        }
        
        previouseMonth  = month;
        previouseYear = year;
    }
    
    self.values = [values copy];
    self.dates = [dates copy];
    
    double range = maxClose - minClose;
    //шаг деления сетки (в натуральном выражении)

    
    if (maxClose == minClose)
    {
        range = maxClose/2;
    }
        
    
    int rank = (int) (log(range)/log(10));
    self.rank = rank;

    double calculatedValueStep = pow(10, rank);
    
    //Если шаг для сетки получился большой, то уменьшить кратно 5
    if (range/calculatedValueStep < 4)
    {
        calculatedValueStep = calculatedValueStep/5;
    }

    self.graphVaueStep = calculatedValueStep;

    
    //минимальное и максимальное значпение на графике, выровненное по десятичным значениям
    double graphValueMin = floor(( (minClose > calculatedValueStep) ? (minClose - calculatedValueStep) : 0 ) /calculatedValueStep) * calculatedValueStep;
    double graphValueMax = ceil((maxClose + calculatedValueStep)/calculatedValueStep) * calculatedValueStep;
    
    //диапазон значений
    double graphValueRange = graphValueMax - graphValueMin;
    
    self.graphValueMin = graphValueMin;
    self.graphValueMax = graphValueMax;
    self.graphValueRange = graphValueRange;
    
    
    //дополнительный отступ оси Y вправо для размещения слева маркировки, расчитывается из оценки количества цифр надписях маркировки - три поинта на каждый знак разряда
    int indentAxisY = (rank > 0 ? rank + 2 :  3 - rank) * 5;
    
    //дополнительный отступ оси X вверх для размещения внизу маркировки
    int indentAxisX = 30;
    
    
    
    self.indentAxisY = indentAxisY;
    self.indentAxisX = indentAxisX;
    
}
    
    
    

/**
 Вычисление коэффициентов масштаба на основании размера UIView, диапазона данных, и длины временного ряда
 
 @param frame размеры UIView для отображения графика
 */
- (void)calculateScaleWithFrame:(CGRect)frame
{
    //шаг по Х в поинтах, если значений в истории мало, то они равномерно распределятся по ширине экрана, если много, то на каждое значение из истории будет один поинт
    double dX = (CGRectGetWidth(frame) - 20) / self.values.count;
    self.dX = dX;

    //высотра графика
    double heightY = CGRectGetHeight(frame);
    self.heightY = heightY;

    //масштаб по Y в поинтах
    double scaleY = 1;
    if (self.graphValueRange != 0) {
        scaleY = (heightY - self.indentAxisX - 10) / self.graphValueRange ;
        NSLog(@"calculatedValueStep %f",  self.graphVaueStep * scaleY );

    }
    self.scaleY = scaleY;
    
}
@end


