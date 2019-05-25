//
//  GraphViewController.m
//  WorldTradingData
//
//  Created by Павел Нехорошкин on 18.05.2019.
//  Copyright © 2019 Павел Нехорошкин. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *graphView;
@property (nonatomic, strong) GraphService *graphData;

@end

@implementation GraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self prepareUI];
}


/**
 Формирование интерфейса, отображение кнопки удаления истории актива и UIScrollView с графиком изменения цены актива
 */
- (void)prepareUI
{
    //кнопка удаления истории актива
    UIImage* deleteButtonImage = [UIImage imageNamed:@"delete.png"];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:deleteButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = deleteButton;
    
    GraphService *graphData = [[GraphService alloc] init];
    
    [graphData calculateCommonDataFromHistory:self.stockHistory];
    
    //отступ справа и слева по 10, дополгнительный отступ graphData.indentAxisY для надписей к оси Y
    CGFloat scrollViewWidth = (self.view.bounds.size.width - 10 - 10 - graphData.indentAxisY);
    //высота UIScrollView для графика
     CGFloat scrollViewHeight = self.view.bounds.size.height - 75 - 10;
    
     UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(10 + graphData.indentAxisY, 75, scrollViewWidth, scrollViewHeight)];
    
    // если мало значений, то графика растягивается до ширины UIScrollView, если значений много (не войдут по ширине) то ширина равна количеству значений в истории торгов (на каждое значение на графике будет 1 поинт по ширине)
    CGFloat graphWidth = (scrollViewWidth > ([self.stockHistory count] + 20) ? scrollViewWidth : [self.stockHistory count] + 20);
    
    //высота графика
    CGFloat graphHeight = scrollViewHeight;
    
    UIView *graphView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, graphWidth, graphHeight)];
    
    //содержимое в scrollView по ширине графика
    scrollView.contentSize = graphView.bounds.size;
    scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [graphData calculateScaleWithFrame:graphView.frame];
    
    [self drawGraphByView:graphView graphData:graphData];
    
    if (scrollViewWidth < graphWidth)
    {
        CGPoint rightOffset = CGPointMake(graphWidth - scrollViewWidth, 0);
        [scrollView setContentOffset:rightOffset animated:YES];
    }
    
    [scrollView addSubview:graphView];
    
    [self.view addSubview:scrollView];
    
    [self drawMarksAxisYByFrame:scrollView.frame graphData:graphData];
    
    //сдвиг оси Y вправо уже учтен в scrollView.frame, дополнительно сдвигать ось не нужно
    [self drawAxisByFrame:scrollView.frame indentAxisY:0 indentAxisX:graphData.indentAxisX];
    
    [self drawMarksAxisX:graphView  graphData:graphData];
}


/**
 Отрисовать на главном экране маркировку и сетку по оси Y (маркировка и сетка не должны двигаться при прокрутке)

 @param frame CGRect с размерами графика
 @param graphData всепомогатльный объект с данными для отрисовки элементов графика
 */
- (void)drawMarksAxisYByFrame:(CGRect)frame graphData:(GraphService *)graphData
{
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.fillColor = [[UIColor clearColor] CGColor];
    lineLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    
    UIBezierPath* lineY = [UIBezierPath bezierPath];
    [lineY setLineWidth:1.0];
    
    double x0 = 10 + graphData.indentAxisY;
    double x1 = CGRectGetMaxX(frame);
    
    CGPoint point;
    
    for (double value = 0; value <= graphData.graphValueRange ; value = value + graphData.graphVaueStep )
    {
        double y = CGRectGetMaxY(frame) - graphData.indentAxisX - value * graphData.scaleY;
        
        UILabel * labelY = [[UILabel alloc] initWithFrame:CGRectMake(5,  y - 10, graphData.indentAxisY, 10)];
        [labelY setFont:[UIFont systemFontOfSize:8]];
        
        NSString *format = (graphData.rank > 0 ? @"%.0f" : [NSString stringWithFormat:@"%%.%df", (1 - graphData.rank)]);
        [labelY setText:[NSString stringWithFormat:format, value + graphData.graphValueMin]];
        [self.view addSubview:labelY];
        
        point = CGPointMake(x0, y);
        [lineY moveToPoint:point];
        
        point = CGPointMake(x1, y);
        [lineY addLineToPoint:point];
    }
    
    lineLayer.opacity = 1.0;
    lineLayer.path = lineY.CGPath;
    
    [self.view.layer addSublayer:lineLayer];
}

/**
 Отрисовывает вынешние линии осей графика, которые при прокрутке остаются неподвижными

 @param frame размеры UIScrollView с графиком, в котором нужно отрисовать оси
 @param indentAxisY  сдвиг влево шкалы Y
 @param indentAxisX сдвиг вверх шкалы X

 */
- (void)drawAxisByFrame:(CGRect)frame indentAxisY:(int)indentAxisY indentAxisX:(int)indentAxisX
{
    
    CAShapeLayer *axisLayer = [CAShapeLayer layer];
    axisLayer.fillColor = [[UIColor clearColor] CGColor];
    axisLayer.strokeColor = [UIColor blueColor].CGColor;
    
    UIBezierPath* axisX = [UIBezierPath bezierPath];
    [axisX setLineWidth:1.0];
    
    //верхняя точка оси Y
    CGPoint point0 = CGPointMake(CGRectGetMinX(frame)+indentAxisY, CGRectGetMinY(frame));
    [axisX moveToPoint:point0];
    
    //стрелка оси Y
    CGPoint point = CGPointMake(CGRectGetMinX(frame)+indentAxisY - 5, CGRectGetMinY(frame) + 5);
    [axisX addLineToPoint:point];
    
    point = CGPointMake(CGRectGetMinX(frame)+indentAxisY + 5, CGRectGetMinY(frame) + 5);
    [axisX moveToPoint:point];
    
    [axisX addLineToPoint:point0];
    
    //начало координат
    point = CGPointMake(CGRectGetMinX(frame)+indentAxisY, CGRectGetMaxY(frame) - indentAxisX);
    [axisX addLineToPoint:point];
    
    //правая конечная точка оси X
    point0 = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame) - indentAxisX);
    [axisX addLineToPoint:point0];
    
    
    //стрелка оси Y
    point = CGPointMake(CGRectGetMaxX(frame) - 5, CGRectGetMaxY(frame) - indentAxisX - 5);
    [axisX addLineToPoint:point];
    
    point = CGPointMake(CGRectGetMaxX(frame) - 5, CGRectGetMaxY(frame) - indentAxisX + 5);
    [axisX moveToPoint:point];
    
    [axisX addLineToPoint:point0];
    
    axisLayer.opacity = 1.0;
    axisLayer.path = axisX.CGPath;
    [self.view.layer addSublayer:axisLayer];
    
}


/**
 Отрисовывает данные GraphData на графике
 
 @param view объект UIView в котором выполняется отрисовка
 @param graphData вспмогательный объект с данными о истории торгов, минимальных и максимальных значениях, коэффициенте масштабирования и проч.
 */
- (void)drawGraphByView:(UIView *)view  graphData:(GraphService *)graphData
{
    CAShapeLayer *graphLayer = [CAShapeLayer layer];
    //Конец и начало линии заокругленныt
    graphLayer.lineCap = kCALineCapRound;
    //Переход между линиями закругленный
    graphLayer.lineJoin = kCALineJoinBevel;
    //Cлой прозрачный
    graphLayer.fillColor = [[UIColor clearColor] CGColor];
    graphLayer.lineWidth = 3;
    graphLayer.opacity = 1.0;
    graphLayer.strokeColor = [UIColor redColor].CGColor;

    UIBezierPath* path = [UIBezierPath bezierPath];
    [path setLineWidth:1.0];
    [path setLineCapStyle:kCGLineCapRound];
    [path setLineJoinStyle:kCGLineJoinRound];

    //Рассчет координат начальной точки
    double x = 5;
    double value = [([graphData.values firstObject]) doubleValue];

    //внизу оставляем место для подписей к оси X (axisXMarkAreaHeight), ось рисуется на графике, чтобы она двигалась вместе с ним
    CGPoint point = CGPointMake(x, graphData.heightY - graphData.indentAxisX - (value - graphData.graphValueMin) * graphData.scaleY);

    [path moveToPoint:point];

    for(NSDecimalNumber *decimalValue in graphData.values) {
        value = [decimalValue doubleValue];

        //внизу оставляем место для подписей к оси X (axisXMarkAreaHeight), ось рисуется на графике, чтобы она двигалась вместе с ним
        point = CGPointMake(x, graphData.heightY - graphData.indentAxisX - (value - graphData.graphValueMin) * graphData.scaleY);

        x = x + graphData.dX;

        [path addLineToPoint:point];
    }

    graphLayer.path = path.CGPath;

    [view.layer addSublayer:graphLayer];

    graphLayer.strokeEnd = 1.0;
}


/**
 Отобразить маркировку по оси X

 @param view UIView графика (маркировка должна быть на самом графике, чтобы двигаться вместе с ним при прокрутке)
 @param graphData вспмогательный объект с данными о истории торгов, минимальных и максимальных значениях, коэффициенте масштабирования и проч.
 */
- (void)drawMarksAxisX:(UIView *)view  graphData:(GraphService *)graphData
{
    double x = 5;
    double y = CGRectGetMaxY(view.bounds) - graphData.indentAxisX + 10;
    
    
    for(NSObject *date in graphData.dates) {
        
        if ([date isKindOfClass:[NSString class]])
        {
            UILabel * labelY = [[UILabel alloc] initWithFrame:CGRectMake(x, y , 35, 10)];
            [labelY setFont:[UIFont systemFontOfSize:8]];
            [labelY setText:(NSString *)date];
            labelY.transform = CGAffineTransformMakeRotation (M_PI / 4);
            [view addSubview:labelY];
        }
             
        x = x + graphData.dX;
    }
}

/**
 Удаляет историю для отображаемого актива по нажатию кноки в верхнем правом углу
 */
- (void)deleteButtonPressed
{
    [self.controller deleteHistory:self.stockHistory];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
