//
//  BlinkView 1.0.0.1
//
//  Created by tyabuta on 2013/04/19.
//  Copyright (c) 2013 tyabuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlinkView : UIView

/*
 * imageViewプロパティのimageを変更する事で、点滅させるイメージを変更できる。
 */
@property(strong, nonatomic) UIImageView* imageView;

/*
 * 初期化メソッド
 */
- (id)initWithImage:(UIImage*)image frame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame;

/*
 * 点滅の開始と、終了を制御できる。
 */
- (void)stopBlink;
- (void)startBlink;
@end

