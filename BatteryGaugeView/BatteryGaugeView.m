
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
 * コンテキストに角丸矩形のPathを追加する。
 */
static inline void
CGContextAddRoundRect(CGContextRef context, CGRect rect, CGFloat radius){
    float top   = rect.origin.y;
    float bottom= top  + rect.size.height;
    float left  = rect.origin.x;
    float right = left + rect.size.width;
    
    CGContextMoveToPoint(context, left, top + (rect.size.height/2));
    CGContextAddArcToPoint(context,  left,    top, right,    top, radius);
    CGContextAddArcToPoint(context, right,    top, right, bottom, radius);
    CGContextAddArcToPoint(context, right, bottom,  left, bottom, radius);
    CGContextAddArcToPoint(context,  left, bottom,  left,    top, radius);
    CGContextClosePath(context);
}

/*
 * コンテキストに角丸矩形のPathを追加する。
 * UIRectCorner列挙体を使用して、丸める角を指定できる。
 */
static inline void
CGContextAddRoundRectByRoundingCorners
(CGContextRef context, CGRect rect, CGFloat radius, UIRectCorner corners){
    
    float top   = rect.origin.y;
    float middle= top + (rect.size.height/2);
    float bottom= top  + rect.size.height;
    
    float left  = rect.origin.x;
    float center= rect.origin.x + (rect.size.width/2);
    float right = left + rect.size.width;
    
    
    CGContextMoveToPoint(context, left, middle);
    
    CGContextAddArcToPoint(context,
                           left,top, center,top,
                           (corners & UIRectCornerTopLeft)?
                           radius : 0.0f);
    
    CGContextAddArcToPoint(context,
                           right,top, right,middle,
                           (corners & UIRectCornerTopRight)?
                           radius : 0.0f);
    
    CGContextAddArcToPoint(context,
                           right,bottom, center,bottom,
                           (corners & UIRectCornerBottomRight)?
                           radius : 0.0f);
    
    CGContextAddArcToPoint(context,
                           left,bottom, left,middle,
                           (corners & UIRectCornerBottomLeft)?
                           radius : 0.0f);
    
    CGContextClosePath(context);
}

/*
 * ２色の線形グラデーションを行う。
 */
static inline void CGContextDrawLinearGradientWithTwoColor
(CGContextRef context,
 CGColorRef color1, CGColorRef color2,
 CGPoint    point1, CGPoint    point2)
{
    const float* c1 = CGColorGetComponents(color1);
    const float* c2 = CGColorGetComponents(color2);
    CGFloat components[8];
    for (int i=0; i<4; i++){
        components[i]   = c1[i];
        components[i+4] = c2[i];
    }
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient =
    CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    CGContextDrawLinearGradient(context, gradient, point1, point2, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

















#pragma mark Class implementation


static const float SMALL_RADIUS = 5.0f;
static const float LARGE_RADIUS = 10.0f;
static const float SHADOW_SIZE  = 3.0f;
static const float BLUR_SIZE    = 3.0f;


@implementation BatteryGaugeView
{
    float     _batteryLevel;
    UILabel*  _displayLabel;
    
    // バッテリー外枠矩形
    CGRect _largeFrame;

    // バッテリー内枠矩形
    CGRect _smallFrame;

    // バッテリー枠の突起用矩形
    CGRect _projectionFrame;

    // バッテリー容量ゲージ矩形
    CGRect _gaugeFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 背景色（デフォルトでクリアカラー）
        self.backgroundColor = [UIColor clearColor];

        // バッテリー通知の登録
        registerBatteryNotificationObserver(self, @selector(update));

        // パーセント表示用のラベル
        _displayLabel = [[UILabel alloc] initWithFrame:CGRectNull];
        [self addSubview:_displayLabel];
        _displayLabel.textAlignment   = NSTextAlignmentCenter;
        _displayLabel.shadowOffset    = CGSizeMake(1.0f, 1.0f);
        _displayLabel.shadowColor     = [UIColor blackColor];
        _displayLabel.textColor       = [UIColor yellowColor];
        _displayLabel.backgroundColor = [UIColor clearColor];
        _displayLabel.font            = [UIFont systemFontOfSize:22.0f];

        // 初回更新
        [self update];
    }
    return self;
}

- (void)dealloc
{
    // バッテリー通知登録の抹消
    removeObserverOfNotificationCenter(self);
}

- (void)layoutSubviews{

    const float margin = 10.0f;
    const float border = 5.0f;
    const float projectionWidth  = 8.0f;
    const float projectionHeight = 20.0f;

    CGRect frame = self.bounds;
    _largeFrame = CGRectMake(margin, margin,
                             frame.size.width  - projectionWidth - (margin*2),
                             frame.size.height - (margin*2));
    
    _smallFrame = CGRectInset(_largeFrame, border, border);
    
    _projectionFrame = CGRectMake(CGRectGetMaxX(_largeFrame),
                                  (frame.size.height - projectionHeight) / 2,
                                  projectionWidth,
                                  projectionHeight);
    
    _displayLabel.frame = _smallFrame;
}


- (void)update
{
    UIDevice* device = [UIDevice currentDevice];
    _batteryLevel = device.batteryLevel;
    
    if (_batteryLevel > 0.0f){
        _displayLabel.text = [NSString stringWithFormat:@"%3d%%", (int)(_batteryLevel*100.0f)];
    }
    else {
        _displayLabel.text = @"---%";
    }

    
    [self setNeedsDisplay];
}


#pragma mark Draw functions

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBatteryFrame:context];
    [self drawBatteryGauge:context];
}

- (void)drawBatteryGauge:(CGContextRef)context {
    CGContextSaveGState(context);

    CGContextSetShouldAntialias(context, YES);
        
    // 容量ゲージの幅を計算
    _gaugeFrame = CGRectInset(_smallFrame, 4, 4);
    _gaugeFrame.size.width *= ((_batteryLevel<0.0f)? 1.0f:_batteryLevel);

    // フレーム枠内に描画エリアを限定
    CGContextAddRoundRect(context, _smallFrame, SMALL_RADIUS);
    CGContextClip(context);
    
    // ゲージ用のPathを作成
    CGPathRef path = NULL;
    CGContextAddRoundRect(context, _gaugeFrame, SMALL_RADIUS);
    path = CGContextCopyPath(context);
    
    // 影の描画
    CGContextSetRGBFillColor(context, 0.5f, 1.0f, 0.5f, 1.0f);
    CGContextSetShadow(context, CGSizeMake(SHADOW_SIZE, SHADOW_SIZE), BLUR_SIZE);
    CGContextFillPath(context);
    
    // グラデーション描画
    CGContextAddPath(context, path);
    CGContextClip(context);
    UIColor* color1 = [UIColor colorWithRed:0.3f green:1.0f blue:0.3f alpha:1.0f];
    UIColor* color2 = [UIColor colorWithRed:0.2f green:0.5f blue:0.2f alpha:1.0f];
    CGPoint p1 = CGPointMake(0, CGRectGetMinY(_gaugeFrame));
    CGPoint p2 = CGPointMake(0, CGRectGetMaxY(_gaugeFrame));
    CGContextDrawLinearGradientWithTwoColor(context, color1.CGColor, color2.CGColor, p1, p2);
    
    // Pathの解放
    CGPathRelease(path);
    
    CGContextRestoreGState(context);
}

- (void)drawBatteryFrame:(CGContextRef)context {
    CGContextSaveGState(context);
    
    CGContextSetShouldAntialias(context, YES);
    
    // Pathの作成
    CGPathRef path = NULL;
    CGContextAddRoundRect(context, _largeFrame, LARGE_RADIUS);
    CGContextAddRoundRect(context, _smallFrame, SMALL_RADIUS);
    CGContextAddRoundRectByRoundingCorners(context, _projectionFrame,
                                           SMALL_RADIUS,
                                           UIRectCornerTopRight | UIRectCornerBottomRight);
    path = CGContextCopyPath(context);
    
    // 影の描画
    CGContextSetRGBFillColor(context, 0.8f, 0.8f, 0.8f, 1.0f);
    CGContextSetShadow(context, CGSizeMake(SHADOW_SIZE, SHADOW_SIZE), BLUR_SIZE);
    CGContextEOFillPath(context);

    // グラデーション描画
    CGContextAddPath(context, path);
    CGContextEOClip(context);
    UIColor* color1 = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor* color2 = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.0f];
    CGPoint p1 = CGPointMake(0, CGRectGetMinY(_largeFrame));
    CGPoint p2 = CGPointMake(0, CGRectGetMaxY(_largeFrame));
    CGContextDrawLinearGradientWithTwoColor(context, color1.CGColor, color2.CGColor, p1, p2);

    // Pathの解放
    CGPathRelease(path);

    CGContextRestoreGState(context);
}



@end




