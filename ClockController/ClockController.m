
#import "ClockController.h"
#import <QuartzCore/QuartzCore.h>

#define WIDTH  170
#define HEIGHT 60


@implementation ClockController
{
    UILabel*         _label;
    NSDateFormatter* _formatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _formatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // 自身のビュー設定
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    float x = self.view.frame.origin.x;
    float y = self.view.frame.origin.y;
    self.view.frame = CGRectMake(x,y,WIDTH,HEIGHT);
    self.view.layer.cornerRadius  = 5.0f;
    self.view.layer.masksToBounds = YES;
    
    // ラベル設定
    _label = [[UILabel alloc] initWithFrame:self.view.bounds];
    _label.font            = [UIFont systemFontOfSize:50.0f];
    _label.textColor       = [UIColor greenColor];
    _label.textAlignment   = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];
    _label.shadowOffset    = CGSizeMake(3.0f, 3.0f);
    _label.shadowColor     = [UIColor blackColor];
    [self.view addSubview:_label];
    
    // タイマーセット
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)tick:(NSTimer*)sender
{
    static int count = 0;
    _formatter.dateFormat = (count++ % 2)? @"HH:mm" : @"HH mm";
    _label.text = [_formatter stringFromDate:[NSDate date]];
}

@end










