//
//  WeightControlHorizontalAxisView.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlHorizontalAxisView.h"

#define ONE_DAY     (24.0 * 60.0 * 60.0)
#define ONE_WEEK    (7.0 * 24.0 * 60.0 * 60.0)
#define ONE_MONTH    (31.0 * 24.0 * 60.0 * 60.0)
#define ONE_YEAR    (365.0 * 24.0 * 60.0 * 60.0)

@implementation WeightControlHorizontalAxisView

@synthesize isZooming, zoomScale, startTimeInterval, verticalGridLinesInterval, step, drawingOffset, timeDimension;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(verticalGridLinesInterval==0) return;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Drawing horizontal axis line
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextMoveToPoint(context, 0.0, 1.0);
    CGContextAddLineToPoint(context, self.frame.size.width, 1.0);
    CGContextStrokePath(context);
    
    
    //Labeling Axis
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    NSUInteger i;
    NSString *curXAxisLabel;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSDate *curDate;
    //NSUInteger numOfLabels = (rect.origin.x + rect.size.width) / verticalGridLinesInterval;
    UIFont *labelFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    float correctStartTime = 0;
    if(step==ONE_DAY){
        dateFormatter.dateFormat = @"dd";
    }else if (step==ONE_WEEK){
        dateFormatter.dateFormat = @"dd.MM";
    }else if (step==ONE_MONTH){
        dateFormatter.dateFormat = @"MMM";
        float ti = [self firstDayOfMonth:startTimeInterval];
        correctStartTime = (float)startTimeInterval - ti;
        
    }else if (step==ONE_YEAR){
        dateFormatter.dateFormat = @"YYYY";
    };
    
    NSInteger pointsInOffsetZone = floor(drawingOffset*timeDimension / step);
    float startDrawing = drawingOffset - (pointsInOffsetZone*step)/timeDimension - (correctStartTime / timeDimension);
    //numOfLabels += pointsInOffsetZone;
    NSTimeInterval startTimeIntervalWithOffsetZone = (float)startTimeInterval - (float)((int)pointsInOffsetZone * (float)step) - correctStartTime;
    float curGridLineX = startDrawing;
    for(i=(startDrawing>30 ? 0 : 1); curGridLineX<=(rect.origin.x+rect.size.width); i++){
        curGridLineX = i*verticalGridLinesInterval + startDrawing;
        if(isZooming){      // show strokes while zooming
            CGContextMoveToPoint(context, curGridLineX, 0.0);
            CGContextAddLineToPoint(context, curGridLineX, 10.0);
        }else{              // show dates
            curDate = [NSDate dateWithTimeIntervalSince1970:startTimeIntervalWithOffsetZone + step * i];
            curXAxisLabel = [dateFormatter stringFromDate:curDate];
            CGSize labelSize = [curXAxisLabel sizeWithFont:labelFont];
            [curXAxisLabel drawAtPoint:CGPointMake(curGridLineX-labelSize.width/2, 0.0) withFont:labelFont];
        };
    };
    
    CGContextStrokePath(context);
    
};

- (NSTimeInterval)firstDayOfMonth:(NSTimeInterval)dateMonth{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSince1970:dateMonth]]; 
    dateComponents.day = 1;
    //dateComponents.hour = 0;
    //dateComponents.minute = 0;
	
    NSDate *tmpDate = [gregorian dateFromComponents:dateComponents];
    NSLog(@"tmpDate = %@", [tmpDate description]);
    NSTimeInterval ret = [tmpDate timeIntervalSince1970];
    
    return ret;
};

- (NSTimeInterval)firstDayOfYear:(NSTimeInterval)dateYear{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:[NSDate dateWithTimeIntervalSince1970:dateYear]];
    dateComponents.month = 1;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;
	
    NSTimeInterval ret = [[gregorian dateFromComponents:dateComponents] timeIntervalSince1970];
    
    return ret;
};

@end