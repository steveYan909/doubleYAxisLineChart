//
//  BMSDoubleYChartView.h
//  UIScrollView滑动方向测试
//
//  Created by BONSOBONSO on 2016/10/11.
//  Copyright © 2016年 BONSOBONSO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMSDoubleYChartView : UIView

@property (nonatomic, strong) id minValue1; // Y1轴的最大值
@property (nonatomic, strong) id maxValue1; // Y1轴的最小值
@property (nonatomic, strong) id minValue2; // Y2轴的最大值
@property (nonatomic, strong) id maxValue2; // Y2轴的最小值

/*
 * x坐标的值和y坐标的值
 * coordinate values, chart will draw itself on layer
 * try to value string to xValues' element or yValues' element
 */
@property (strong, nonatomic) NSArray *XValues;
@property (strong, nonatomic) NSArray *Y1Values;
@property (strong, nonatomic) NSArray *Y2Values;


@property (nonatomic, assign) NSInteger numberOfY1Axis; // Y1轴的文本个数
@property (nonatomic, assign) NSInteger numberOfY2Axis; // Y2轴的文本个数

@end
