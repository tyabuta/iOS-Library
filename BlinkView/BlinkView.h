//
//  BlinkView 1.0.1.2
//
//  Created by tyabuta on 2013/04/19.
//  Copyright (c) 2013 tyabuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlinkView : UIView

/*
 * 初期化メソッド
 */
- (id)initWithImage:(UIImage*)image frame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame;




/*
 * imageViewプロパティのimageを変更する事で、点滅させるイメージを変更できる。
 */
@property(strong, nonatomic) UIImageView* imageView;

/*
 * 点滅の間隔(初期値0.1f -> 0.1sec)
 */
@property(nonatomic) CGFloat interval;

@end


@interface BlinkView(Property)
/*
 * 点滅中ならYES。
 */
- (BOOL)isBlink;
@end


@interface BlinkView(Action)
/*
 * 点滅の開始と、終了を制御できる。
 */
- (void)stopBlink;
- (void)startBlink;

@end


