/*******************************************************************************
  UIDateTextField 1.0.1.2 (2013/03/29)
 
                        日付を選択できるテキストフィールド
 
                                                    (c) 2012 - 2013 tyabuta.
 ******************************************************************************/
#import <UIKit/UIKit.h>

@interface UIDateTextField : UITextField

@property(nonatomic, retain) NSDate* date;

- (id)initWithFrame:(CGRect)frame;
- (BOOL)canBecomeFirstResponder;
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
@end


