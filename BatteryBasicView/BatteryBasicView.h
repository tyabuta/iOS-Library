/*******************************************************************************

                          BatteryBasicView 1.2.0.3

                                                             (c) 2013 tyabuta.
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface BatteryBasicView : UIView

/*
 *　余白（初期値は10.0f）
 */
@property(nonatomic) CGFloat padding;

/*
 * 初期化メソッド
 */
- (id)initWithFrame:(CGRect)frame;
@end
