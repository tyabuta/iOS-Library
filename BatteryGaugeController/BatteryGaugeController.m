#import "BatteryGaugeController.h"
#import <QuartzCore/QuartzCore.h>


@implementation BatteryGaugeController
{
    UILabel* batteryLabel;
}

- (id)initWithParentController:(UIViewController*)parent
{
    self = [super initWithNibName:nil bundle:nil];    
    
    [parent addChildViewController:self];
    [self batterySetupUtilities];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    [self update];
}

- (void)configureView
{
    // ビューの親子関係構築
    [self.parentViewController.view addSubview:self.view];
    [self didMoveToParentViewController:self.parentViewController];

    // 自身のビュー設定
	self.view.layer.cornerRadius = 5.0f;
    self.view.layer.masksToBounds = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin   |
    UIViewAutoresizingFlexibleBottomMargin;
    
    // バッテリー表示用のビュー
    batteryLabel = [[UILabel alloc] init];
    batteryLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    batteryLabel.textColor = [UIColor greenColor];
    batteryLabel.textAlignment = NSTextAlignmentCenter;
    batteryLabel.frame = self.view.bounds;
    batteryLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:batteryLabel];
}

- (void)update
{
    NSString *level, *state;
    [self batteryLevel:&level andState:&state];
    batteryLabel.text = [NSString stringWithFormat:@"%@ (%@)", level, state];
}




/*******************************************************************************
 * バッテリー関係のメソッド
 */

/*
 * バッテリー状態の変更イベント
 * updateメッセージを投げて、表示の更新を依頼する。
 */
- (void)batteryDidChange:(NSNotification *)notification
{
    [self update];
}

/*
 * バッテリー通知を受け取るようにセットアップする。
 */
- (void)batterySetupUtilities
{
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(batteryDidChange:)
                   name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [center addObserver:self
               selector:@selector(batteryDidChange:)
                   name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

/*
 * 現在のバッテリー状態とレベルを文字列で取得する。
 */
- (void)batteryLevel:(NSString**)level andState:(NSString**)state
{
    UIDevice* device = [UIDevice currentDevice];
    float batteryLevel = device.batteryLevel;
    *level = (0.0f > batteryLevel)?
    @"???%" : [NSString stringWithFormat:@"%d%%", (int)(batteryLevel*100)];
    
    switch (device.batteryState) {
        case UIDeviceBatteryStateCharging:
            *state = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            *state = @"Full";
            break;
        case UIDeviceBatteryStateUnplugged:
            *state = @"Unplugged";
            break;
        default:
            *state = @"Unknown";
    }
}

@end





