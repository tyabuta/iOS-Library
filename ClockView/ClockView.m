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
    int              _count;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        // 初期値
        _padding = 10.0f;
        
        // フォーマッター
        _formatter = [[NSDateFormatter alloc] init];
        
        // 初期の文字色はグリーン
        _textColor = [UIColor greenColor];
        
        // ラベル設定
        _label = [[UILabel alloc] initWithFrame:CGRectNull];
        _label.textColor       = _textColor;
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment   = NSTextAlignmentCenter;
        _label.shadowOffset    = CGSizeMake(2.0f, 2.0f);
        _label.shadowColor     = [UIColor blackColor];
        [self addSubview:_label];
        
        // タイマーセット
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(tick:)
                                       userInfo:nil
                                        repeats:YES];
        // 初回更新
        _count = 0;
        [self tick:nil];
    }
    return self;
}

- (void)tick:(NSTimer*)sender
{
    _formatter.dateFormat = (_count++ % 2)? @"HH:mm" : @"HH mm";
    _label.text = [_formatter stringFromDate:[NSDate date]];
}


- (void)setPadding:(CGFloat)padding{
    if (padding != _padding){
        _padding = padding;
        [self setNeedsLayout];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor       = textColor;
    _label.textColor = textColor;
}

- (void)layoutSubviews{
    float w =  self.bounds.size.width;
    float h = self.bounds.size.height;
    
    float font_size    = h - (_padding*2.0f);
    float label_width  = w - (_padding*2.0f);
    float label_height = font_size;
    float label_top    = (h - label_height)/2.0f;
    float label_left   = (w - label_width )/2.0f;
    
    _label.frame = CGRectMake(label_left, label_top, label_width, label_height);
    _label.font = [UIFont systemFontOfSize:font_size];
    
}

@end




