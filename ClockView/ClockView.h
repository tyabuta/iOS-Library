//
//  ClockView.h
//
//  Created by tyabuta on 2013/04/12.
//  Copyright (c) 2013 tyabuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockView : UIView
- (id)initWithFrame:(CGRect)frame;

@property(nonatomic) CGFloat padding;

@property(strong, nonatomic) UIColor* textColor;

@end

