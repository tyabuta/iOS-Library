
#import "BatteryGaugeView.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark Macro functions

/*
 * デバックログ用のマクロ、リリース時は何もおこらないようになる。
 * Tips: __VA_ARGS__ の前に##を付けると、引数ゼロでもコンパイルが通る。
 */
#ifdef DEBUG
#define dmsg(fmt, ...) NSLog((@"%s @%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define dmsg(...)
#endif

/*
 * バッテリステートを文字列で取得します。
 * 関数内でbatteryMonitoringEnabledをYESに設定します。
 */
static inline NSString* getBatteryState(){
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    UIDeviceBatteryState state = device.batteryState;
    
    NSString* stateText = nil;
    switch (state) {
        case UIDeviceBatteryStateCharging:
            stateText = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            stateText = @"Full";
            break;
        case UIDeviceBatteryStateUnplugged:
            stateText = @"Unplugged";
            break;
        default:
            stateText = @"Unknown";
    }
    
    return stateText;
}

/*
 * バッテリレベルを文字列で取得します。
 * 関数内でbatteryMonitoringEnabledをYESに設定します。
 */
static inline NSString* getBatteryLevel(){
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    float batteryLevel = device.batteryLevel;
    
    NSString* levelText = nil;
    if (0.0f > batteryLevel){
        levelText = @"---%";
    }
    else {
        levelText = [NSString stringWithFormat:@"%d%%", (int)(batteryLevel*100)];
    }
    return levelText;
}


/*
 * バッテリ状態通知のオブザーバを登録する。
 *
 * セレクタ例)
 * - (void)batteryDidChange:(NSNotification *)notification
 *
 * notification.name プロパティでどの通知が発生したのかがわかる。
 * UIDeviceBatteryLevelDidChangeNotification
 * UIDeviceBatteryStateDidChangeNotification
 */
static inline void registerBatteryNotificationObserver(id observer, SEL selector){
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:observer
               selector:selector
                   name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [center addObserver:observer
               selector:selector
                   name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

/*
 * 通知センターに登録したオブザーバを削除する。
 * オブザーバに登録したクラスはdealloc メソッドで削除しておく事をおすすめする。
 */
static inline void removeObserverOfNotificationCenter(id observer){
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

/*
 * UIImageからUIImageViewを作成し、parentViewに追加する。 サイズはフィットするように配置される。
 * 成功時には作成したUIImageViewのオブジェクトが返る。
 */
static inline UIImageView*
imageViewAddToParent(UIImage* image, UIView* parentView){
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    // アスペクト比が崩れないように親ビューにフィットさせる。
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = parentView.bounds;
    [parentView addSubview:imageView];
    return imageView;
}

/*
 * UIImageViewをparentViewに追加する。 サイズはフィットするように配置される。
 * 成功時には作成したUIImageViewのオブジェクトが返る。
 */
static inline UIImageView*
imageAddBasicFromResource(NSString* imageName, UIView* parentView){
    UIImage* image = [UIImage imageNamed:imageName];
    if (nil == image) {
        dmsg(@"イメージの読み込みに失敗しました。");
        return nil;
    }
    return imageViewAddToParent(image, parentView);
}






#pragma mark Class implementation


@implementation BatteryGaugeView
{
    CGRect    _gaugeRect;
    float     _battery;
    NSString* _display;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        imageAddBasicFromResource(@"battery.png", self);
        registerBatteryNotificationObserver(self, @selector(update));

        [self update];
    }
    return self;
}

- (void)dealloc
{
    removeObserverOfNotificationCenter(self);
}


- (void)update
{
    UIDevice* device = [UIDevice currentDevice];
    _battery = device.batteryLevel;
    
    if (_battery > 0.0f){
        _display = [NSString stringWithFormat:@"%3d%%", (int)(_battery*100.0f)];
    }
    else {
        _display = @"999%";
    }

    float w = 92 * ((_battery<0.0f)? 1.0f:_battery);
    _gaugeRect = CGRectMake(22, 20, w, 45);
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    // バッテリー容量の描画枠
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:_gaugeRect
                                                          cornerRadius:5];
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetShadow(context, CGSizeMake(4,4), 2);
    [bezierPath fill];
    
    // グラデーション描画
    [bezierPath addClip];
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.5,  1.0,   0.5,  1.0, // Start color
        0.0,  0.7,   0,    1.0  // End color
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient =
    CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint p1 = _gaugeRect.origin;
    CGPoint p2 = CGPointMake(_gaugeRect.origin.x,
                             _gaugeRect.origin.y + _gaugeRect.size.height);
    CGContextDrawLinearGradient(context, gradient, p1, p2, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);


    CGContextRestoreGState(context);
    
    // バッテリー残量描画
    CGContextSetShadow(context, CGSizeMake(2,2), 2);
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    [_display drawAtPoint:CGPointMake(38,28) withFont:[UIFont systemFontOfSize:24]];
}

@end
