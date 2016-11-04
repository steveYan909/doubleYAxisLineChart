//
//  BMSDoubleYChartView.m
//  UIScrollView滑动方向测试
//
//  Created by BONSOBONSO on 2016/10/11.
//  Copyright © 2016年 BONSOBONSO. All rights reserved.
//

#import "BMSDoubleYChartView.h"

#define LINE_CHART_TOP_PADDING 30 // 顶部间距
#define LINE_CHART_LEFT_PADDING 40 // 左边间距
#define LINE_CHART_RIGHT_PADDING 40 // 右边间距
#define LINE_CHART_TEXT_HEIGHT 44 // 40

@interface BMSDoubleYChartView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat chartHeight;

/******收集坐标点******/
@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *Y1Points;
@property (strong, nonatomic) NSMutableArray *Y2Points;
/******收集坐标点******/

@property (strong, nonatomic) NSMutableArray *XAxisLabelArray; // 保存X轴文本

@property (nonatomic, assign) CGFloat maxY1Value;

@property (nonatomic, assign) CGFloat maxY2Value;

@end

@implementation BMSDoubleYChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    CGFloat width = self.bounds.size.width;
    
    self.XAxisLabelArray = [NSMutableArray array];
    
    // 折线图的高度
    self.chartHeight = self.bounds.size.height - LINE_CHART_TOP_PADDING - LINE_CHART_TEXT_HEIGHT;
    
    // Y1、Y2轴显示文本的个数
    _numberOfY1Axis = 5;
    _numberOfY2Axis = 5;
    
    // 1.初始化UIScrollView
    //    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LINE_CHART_LEFT_PADDING, 0, width - 2 * LINE_CHART_LEFT_PADDING, CGRectGetHeight(self.bounds))];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING, width - 2 * LINE_CHART_LEFT_PADDING, CGRectGetHeight(self.bounds)- LINE_CHART_TOP_PADDING) ];
   
    /*****调试*****/
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING-10, width - 2 * LINE_CHART_LEFT_PADDING, CGRectGetHeight(self.bounds)- LINE_CHART_TOP_PADDING) ];
    /*****调试*****/
#warning 必须设置
    // 翻转
    [self.scrollView setTransform:CGAffineTransformMakeScale(-1, 1)];
#warning 必须设置

    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    
    
    // 添加宠物体重说明
    UIView *weightView = [[UIView alloc] initWithFrame:CGRectMake(LINE_CHART_LEFT_PADDING + 10,10,50,3)];
    weightView.backgroundColor = [UIColor redColor];
    [self addSubview:weightView];
    
    UILabel *weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(weightView.frame) + 5,3,76,20)];
    weightLabel.text = @"折线一";
    weightLabel.textColor = [UIColor redColor];
    weightLabel.font = [UIFont systemFontOfSize:12.f];
    [self addSubview:weightLabel];
    
    // 添加宠物喂食说明
    UIView *feedingView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(weightLabel.frame) + 10,10,50,3)];
    feedingView.backgroundColor = [UIColor blueColor];
    [self addSubview:feedingView];
    
    UILabel *feedingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(feedingView.frame) + 5,3,70,20)];
    feedingLabel.text = @"折线二";
    feedingLabel.textColor = [UIColor blueColor];
    feedingLabel.font = [UIFont systemFontOfSize:12.f];
    [self addSubview:feedingLabel];
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 2.绘制坐标轴
    [self drawCoordinate];
    
    // 3.根据Y1、Y2轴的最大值来添加 Y1、Y2轴坐标文本
    [self showY1AxisTextLabel];
    [self showY2AxisTextLabel];
    
    // 4.根据X轴的值来添加 X轴坐标文本，并设置UIScrollView的偏移范围
    [self showXAxisTextLabel];
    
    // 5.绘制Y1轴对应的折线
    [self drawLineY1];
    
    
    // 6.绘制Y2轴对应的折线
    [self drawLineY2];
    
    
}

#pragma mark - 绘制坐标轴
- (void) drawCoordinate
{
    // 2.1 获得上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat width = self.bounds.size.width;
    
    // Y1轴
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextMoveToPoint(context, LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING);
    CGContextAddLineToPoint(context, LINE_CHART_LEFT_PADDING , LINE_CHART_TOP_PADDING + self.chartHeight);
    CGContextStrokePath(context);
    
    // X轴
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING + self.chartHeight);
    CGContextAddLineToPoint(context, width - LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING + self.chartHeight);
    CGContextStrokePath(context);
    
    // Y2轴
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(context, width - LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING);
    CGContextAddLineToPoint(context, width - LINE_CHART_LEFT_PADDING, LINE_CHART_TOP_PADDING + self.chartHeight);
    CGContextStrokePath(context);
}

#pragma mark - 显示Y1轴文本
- (void) showY1AxisTextLabel
{
    [self setUpY1coorWithValues:self.Y1Values];
    
}

- (void) setUpY1coorWithValues:(NSArray *)Y1Values
{
    CGFloat chartYOffset = self.chartHeight;
    
    NSUInteger count = Y1Values.count;
    NSString *maxValue = Y1Values[0];
    for (int i = 1; i < count; i++)
    {
        if ([maxValue floatValue] < [Y1Values[i] floatValue])
        {
            maxValue = Y1Values[i];
            
        }
        
        CGFloat cX = LINE_CHART_LEFT_PADDING + 2;
        CGFloat cY = i * (chartYOffset / count);
        // 收集坐标点
        [self.Y1Points addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
    }
    
    //    int max = (int)(([maxValue floatValue] * 1.2 /(float)10)*10);
    self.maxY1Value = maxValue.floatValue;
    
    /*****调试*****/
    self.maxY1Value = (int)((maxValue.floatValue * 1.2 /(float)10)*10);
    if (self.maxY1Value < 5.0)
    {
        self.maxY1Value = 5;
    }
    /*****调试*****/
    
    chartYOffset = self.chartHeight + LINE_CHART_TOP_PADDING;
    // 1.获得每一个y轴单元的高度
    CGFloat unitHeight = _chartHeight/_numberOfY1Axis;
    
    // 2.得每一个Y1轴单元的值 (最大值-最小值)/Y1轴单元的个数
    CGFloat unitValue1 = ([maxValue floatValue] - [_minValue1 floatValue])/_numberOfY1Axis;
    
    /*****调试*****/
    unitValue1 = (self.maxY1Value  - [_minValue1 floatValue])/_numberOfY1Axis;
    /*****调试*****/
    
    for (NSInteger i = 0; i <= _numberOfY1Axis; i ++)
    {
        CGFloat x = 0;
        CGFloat y = chartYOffset - 10;
        CGFloat labelWidth = LINE_CHART_LEFT_PADDING - 5;
        CGFloat labelHeight = 20;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelWidth,labelHeight)];
        textLabel.textColor = [UIColor orangeColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:11.f];
        textLabel.numberOfLines = 0;
        textLabel.text = [NSString stringWithFormat:@"%.0f", unitValue1 * i + [_minValue1 floatValue]];
        [self addSubview:textLabel];
        
        // 绘制刻度
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
        CGContextMoveToPoint(context, LINE_CHART_LEFT_PADDING-5, chartYOffset);
        CGContextAddLineToPoint(context, LINE_CHART_LEFT_PADDING, chartYOffset);
        CGContextStrokePath(context);
        
        chartYOffset -= unitHeight;
    }
    
    
}

#pragma mark - 显示Y2轴文本
- (void) showY2AxisTextLabel
{
    [self setUpY2coorWithValues:self.Y2Values];
}

- (void) setUpY2coorWithValues:(NSArray *)Y2Values
{
    CGFloat chartYOffset = self.chartHeight;
    
    NSUInteger count = Y2Values.count;
    NSString *maxValue = Y2Values[0];
    for (int i = 1; i < count; i++)
    {
        if ([maxValue floatValue] < [Y2Values[i] floatValue])
        {
            maxValue = Y2Values[i];
        }
        
        CGFloat cX = LINE_CHART_LEFT_PADDING + 2;
        CGFloat cY = i * (chartYOffset / count) + 5;
        // 收集坐标点
        [self.Y1Points addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
    }
    
    //    int max = (int)(([maxValue floatValue] * 1.2 /(float)10)*10);
    self.maxY2Value = maxValue.floatValue;
    
    /*****调试*****/
    self.maxY2Value = (int)((maxValue.floatValue * 1.2 /(float)10)*10);
    
    if (self.maxY2Value < 5.0)
    {
        self.maxY2Value = 5;
    }
    /*****调试*****/
    
    chartYOffset = self.chartHeight + LINE_CHART_TOP_PADDING;
    
    // 1.获得每一个y轴单元的高度
    CGFloat unitHeight = _chartHeight/_numberOfY2Axis;
    
    // 2.得每一个y轴单元的值 (最大值-最小值)/y轴单元的个数
    CGFloat unitValue2 = ([maxValue floatValue] - [_minValue2 floatValue])/_numberOfY2Axis;
    
    /*****调试*****/
    unitValue2 = (self.maxY2Value  - [_minValue2 floatValue])/_numberOfY2Axis;
    /*****调试*****/
    
    for (NSInteger i = 0; i <= _numberOfY2Axis; i ++)
    {
        CGFloat x = self.bounds.size.width - LINE_CHART_LEFT_PADDING +5;
        CGFloat y = chartYOffset - 10;
        CGFloat labelWidth = LINE_CHART_LEFT_PADDING - 5;
        CGFloat labelHeight = 20;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelWidth,labelHeight)];
        textLabel.textColor = [UIColor blueColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:11.f];
        textLabel.numberOfLines = 0;
        textLabel.text = [NSString stringWithFormat:@"%.0f", unitValue2 * i + [_minValue2 floatValue]];
        [self addSubview:textLabel];
        
        // 绘制刻度
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextMoveToPoint(context, self.bounds.size.width - LINE_CHART_LEFT_PADDING, chartYOffset);
        CGContextAddLineToPoint(context, self.bounds.size.width - LINE_CHART_LEFT_PADDING+5, chartYOffset);
        
        CGContextStrokePath(context);
        
        chartYOffset -= unitHeight;
    }
    
}

#pragma mark - 显示X轴文本
- (void) showXAxisTextLabel
{
    [self setUpXcoorWithValues:self.XValues];
}

- (void) setUpXcoorWithValues:(NSArray *)XValues
{
    CGFloat chartYOffset = self.bounds.size.height - LINE_CHART_TEXT_HEIGHT;
    //    chartYOffset = self.chartHeight + LINE_CHART_TOP_PADDING;
    chartYOffset = self.chartHeight;
    CGFloat padding = 5;
    CGFloat labelWidth = LINE_CHART_LEFT_PADDING - 5;
    CGFloat labelHeight = 33;
    CGFloat y = chartYOffset +4;
    
    /*****调试*****/
    y = chartYOffset +4+10;
    /*****调试*****/
    
    if (XValues.count)
    {
        NSUInteger count = XValues.count;
        for (int i = 0; i < count; i++)
        {
            CGFloat x = padding + (padding + labelWidth) * i;
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelWidth, labelHeight)];
            
            textLabel.textColor = [UIColor grayColor];
            textLabel.numberOfLines = 0;
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.font = [UIFont systemFontOfSize:11.f];
            textLabel.numberOfLines = 0;
            textLabel.text = XValues[i];
            [self.scrollView addSubview:textLabel];
            
#warning 必须设置
            // 翻转
            [textLabel setTransform:CGAffineTransformMakeScale(-1, 1)];
#warning 必须设置
            
            CGFloat cX = 0;
            cX = x + labelWidth * 0.5;
            
            // x坐标的y值相等
            CGFloat cY = y;
            
            // 收集坐标点
            [self.xPoints addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
            
            [self.XAxisLabelArray addObject:textLabel];
            
            
        }
    }
    
    // 获得X轴最后一个文本
    UILabel *lastTextLabel = self.XAxisLabelArray.lastObject;
    CGFloat offsetX = CGRectGetMaxX(lastTextLabel.frame);
    
    // 设置scrollView的滚动范围
    self.scrollView.contentSize = CGSizeMake(offsetX, 0);
    
}


- (void) drawLineY1
{
    if (self.XValues.count != 0 && self.Y1Values.count != 0)
    {
        NSMutableArray *funcPoints = [NSMutableArray array];
        NSInteger pointCount = self.Y1Values.count;
        [[UIColor clearColor] set];
        
        if (self.XValues.count != self.Y1Values.count)
        {
            pointCount = (self.XValues.count < self.Y1Values.count ? self.XValues.count : self.Y1Values.count);
        }
        
        /*****调试*****/
        // 圆点
        UIBezierPath *pointBezierPath = [UIBezierPath bezierPath];
        /*****调试*****/
        
        for (int i = 0; i < pointCount; i++)
        {
            CGFloat funcXPoint = [self.xPoints[i] CGPointValue].x;
            CGFloat yValue = [self.Y1Values[i] floatValue];
            
//            NSLog(@"maxY1Value:%f",self.maxY1Value);
            // 根据对应y坐标的值，来获得坐标中该点的y值
            //            CGFloat funcYPoint = (self.chartHeight + LINE_CHART_TOP_PADDING) - (yValue / self.maxY1Value) * (self.chartHeight);
            CGFloat funcYPoint = (self.chartHeight) - (yValue / self.maxY1Value) * (self.chartHeight);
            
            /*****调试*****/
            funcYPoint = (self.chartHeight) - (yValue / self.maxY1Value) * (self.chartHeight) + 10;
            /*****调试*****/
            
            [funcPoints addObject:[NSValue valueWithCGPoint:CGPointMake(funcXPoint, funcYPoint)]];
            
            /*****调试*****/
            // 圆点
            [pointBezierPath moveToPoint:CGPointMake(funcXPoint + 3, funcYPoint)];
            [pointBezierPath addArcWithCenter:CGPointMake(funcXPoint, funcYPoint) radius:3 startAngle:0 endAngle:2 * M_PI clockwise:YES];
            /*****调试*****/
        }
        
        
        
        
        //        if (index == 0)
        //        {
        //            [lineBezierPath moveToPoint:CGPointMake(xOffset, yOffset)];
        //
        //        } else {
        //            [lineBezierPath addLineToPoint:CGPointMake(xOffset, yOffset)];
        //        }
        
        // 线段
        UIBezierPath *funcLinePath = [UIBezierPath bezierPath];
        [funcLinePath moveToPoint:[[funcPoints firstObject] CGPointValue]];
        [funcLinePath setLineCapStyle:kCGLineCapRound];
        [funcLinePath setLineJoinStyle:kCGLineJoinRound];
        int index = 0;
        for (NSValue *pointValue in funcPoints)
        {
            if (index != 0)
            {
                [funcLinePath addLineToPoint:[pointValue CGPointValue]];
                [funcLinePath moveToPoint:[pointValue CGPointValue]];
                [funcLinePath stroke];
            }
            
            
            // 圆点
            
            index++;
        }
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.lineCap = kCALineCapRound;
        lineLayer.lineJoin = kCALineJoinRound;
        lineLayer.strokeColor = [UIColor redColor].CGColor;
        lineLayer.strokeEnd   = 0.0;
        lineLayer.lineWidth   = 2.0;
        lineLayer.path = funcLinePath.CGPath;
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        pathAnimation.autoreverses = NO;
        [lineLayer addAnimation:pathAnimation forKey:@"lineLayerAnimation"];
        lineLayer.strokeEnd = 1.0;
        [self.scrollView.layer addSublayer:lineLayer];
        
        /*****调试*****/
        CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
        pointLayer.strokeColor = [UIColor orangeColor].CGColor;
        pointLayer.fillColor = [UIColor orangeColor].CGColor;
        pointLayer.path = pointBezierPath.CGPath;
        [_scrollView.layer insertSublayer:pointLayer above:lineLayer];
        /*****调试*****/
        
    }
    
}

- (void) drawLineY2
{
    if (self.XValues.count != 0 && self.Y2Values.count != 0)
    {
        NSMutableArray *funcPoints = [NSMutableArray array];
        NSInteger pointCount = self.Y2Values.count;
        [[UIColor clearColor] set];
        
        if (self.XValues.count != self.Y2Values.count)
        {
            pointCount = (self.XValues.count < self.Y2Values.count ? self.XValues.count : self.Y2Values.count);
        }
        
        /*****调试*****/
        // 圆点
        UIBezierPath *pointBezierPath = [UIBezierPath bezierPath];
        /*****调试*****/
        
        for (int i = 0; i < pointCount; i++)
        {
            CGFloat funcXPoint = [self.xPoints[i] CGPointValue].x;
            CGFloat yValue = [self.Y2Values[i] floatValue];
            
            // 根据对应y坐标的值，来获得坐标中该点的y值
            
            //            NSLog(@"self.maxY2Value:%f",self.maxY2Value);
            //            CGFloat funcYPoint = (self.chartHeight+ LINE_CHART_TOP_PADDING) - (yValue / self.maxY2Value) * (self.chartHeight);
            CGFloat funcYPoint = (self.chartHeight) - (yValue / self.maxY2Value) * (self.chartHeight);
            
            /*****调试*****/
            funcYPoint = (self.chartHeight) - (yValue / self.maxY2Value) * (self.chartHeight) + 10;
            /*****调试*****/
            
            [funcPoints addObject:[NSValue valueWithCGPoint:CGPointMake(funcXPoint, funcYPoint)]];
            
            /*****调试*****/
            // 圆点
            [pointBezierPath moveToPoint:CGPointMake(funcXPoint + 3, funcYPoint)];
            [pointBezierPath addArcWithCenter:CGPointMake(funcXPoint, funcYPoint) radius:3 startAngle:0 endAngle:2 * M_PI clockwise:YES];
            /*****调试*****/
        }
        
        UIBezierPath *funcLinePath = [UIBezierPath bezierPath];
        [funcLinePath moveToPoint:[[funcPoints firstObject] CGPointValue]];
        [funcLinePath setLineCapStyle:kCGLineCapRound];
        [funcLinePath setLineJoinStyle:kCGLineJoinRound];
        int index = 0;
        for (NSValue *pointValue in funcPoints)
        {
            if (index != 0)
            {
                [funcLinePath addLineToPoint:[pointValue CGPointValue]];
                [funcLinePath moveToPoint:[pointValue CGPointValue]];
                [funcLinePath stroke];
            }
            index++;
        }
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.lineCap = kCALineCapRound;
        lineLayer.lineJoin = kCALineJoinRound;
        lineLayer.strokeColor = [UIColor blueColor].CGColor;
        lineLayer.strokeEnd   = 0.0;
        lineLayer.lineWidth   = 2.0;
        lineLayer.path = funcLinePath.CGPath;
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        pathAnimation.autoreverses = NO;
        [lineLayer addAnimation:pathAnimation forKey:@"lineLayerAnimation"];
        lineLayer.strokeEnd = 1.0;
        [self.scrollView.layer addSublayer:lineLayer];
        
        /*****调试*****/
        CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
        pointLayer.strokeColor = [UIColor greenColor].CGColor;
        pointLayer.fillColor = [UIColor greenColor].CGColor;
        pointLayer.path = pointBezierPath.CGPath;
        [_scrollView.layer insertSublayer:pointLayer above:lineLayer];
        /*****调试*****/
    }
    
}

#pragma mark - 懒加载
-(NSMutableArray *) xPoints
{
    if (_xPoints == nil)
    {
        _xPoints = [NSMutableArray array];
    }
    return _xPoints;
}

-(NSMutableArray *) Y1Points
{
    if (_Y1Points == nil)
    {
        _Y1Points = [NSMutableArray array];
    }
    return _Y1Points;
}

- (NSMutableArray *)Y2Points
{
    if (_Y2Points == nil)
    {
        _Y2Points = [NSMutableArray array];
    }
    return _Y2Points;
}





@end

