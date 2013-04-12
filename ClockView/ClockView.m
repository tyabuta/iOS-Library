//
//  ClockView.m
//
//  Created by tyabuta on 2013/04/12.
//  Copyright (c) 2013 tyabuta. All rights reserved.
//

#import "ClockView.h"

@implementation ClockView
{
    UILabel*         _label;
    NSDateFormatter* _formatter;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _formatter = [[NSDateFormatter alloc] init];
        
        // ラベル設定
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.font            = [UIFont systemFontOfSize:50.0f];
        _label.textColor       = [UIColor greenColor];
        _label.textAlignment   = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.shadowOffset    = CGSizeMake(3.0f, 3.0f);
        _label.shadowColor     = [UIColor blackColor];
        [self addSubview:_label];
        
        // タイマーセット
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(tick:)
                                       userInfo:nil
                                        repeats:YES];
        // 初回更新
        [self tick:nil];
    }
    return self;
}

- (void)tick:(NSTimer*)sender
{
    static int count = 0;
    _formatter.dateFormat = (count++ % 2)? @"HH:mm" : @"HH mm";
    _label.text = [_formatter stringFromDate:[NSDate date]];
}


- (void)layoutSubviews{
    _label.frame = self.bounds;
}


@end
