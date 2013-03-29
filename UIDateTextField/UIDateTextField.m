
#import "UIDateTextField.h"


static NSString* const dateFormat_ = @"YYYY年 MM月 dd日";

// NSDateを文字列に変換
static NSString* stringFromDate(NSDate* date){
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat_];
    
    return [formatter stringFromDate:date];
}

// 日付文字列からNSDateに変換
static NSDate* dateFromString(NSString* str_date){
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat_];
    
    return [formatter dateFromString:str_date];
}


// inputAccessoryView用のUITollBarを作成する
// target: デリゲートを備えたクラス
// acrion: Doneボタンを押した際のメソッド名
static UIToolbar* createToolBar(id target, SEL action){
    
    UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem* spacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    
    UIBarButtonItem* button = 
    [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                     style:UIBarButtonItemStyleDone
                                    target:target
                                    action:action];
    
    toolBar.items = [NSArray arrayWithObjects:spacer, button, nil];
    return toolBar;
}




@interface UIDateTextField(){
    UIDatePicker* picker_;
    UIToolbar*    toolbar_;
}
@end

@implementation UIDateTextField

- (void)setDate:(NSDate*)aDate {
    if (aDate){
        picker_.date = aDate;
        self.text = stringFromDate(aDate);
    }
}

- (NSDate*)date{
    return picker_.date;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        // inputAccessoryViewを作成
        toolbar_ = createToolBar(self, @selector(dateSelected:));
        self.inputAccessoryView = toolbar_;
        
        // UIDatePickerを作成する
        picker_ = [[UIDatePicker alloc] init];
        picker_.datePickerMode = UIDatePickerModeDate;
        [picker_ addTarget:self
                    action:@selector(dateChange:)
          forControlEvents:UIControlEventValueChanged];    
        self.inputView = picker_;
    }
    return self;
}

// Doneボタンタッチイベント
- (void)dateSelected:(id)sender{
    [self resignFirstResponder];
}

// UIDatePicker変更イベント
- (void)dateChange:(UIDatePicker*)sender{
    
    // UIDatePickerの日付を文字列に変換
    NSString* str = stringFromDate(sender.date);
    
    // UITextFieldに反映する
    self.text = str;
}

// UITextFieldの編集開始直前のイベント
- (BOOL)canBecomeFirstResponder{
    // UITextFieldの日付をUIDatePickerに反映させる。
    NSDate* date = nil;
    if ((date = dateFromString([self text])) != nil){
        picker_.date = date;
    }
    // UITextFieldが空の場合、UIDatePickerの日付を反映させる。
    else {
        self.text = stringFromDate(picker_.date);
    }
    
    return YES; // YESを返すと、編集を許可する。
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:)) return YES;
    
    return NO;
}

@end

































