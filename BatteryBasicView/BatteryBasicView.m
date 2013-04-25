
#import "BatteryBasicView.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Macro functions

#if 0 // Enable macro.h
#import "macro.h"
#else

/*
 * 配列個数の取得
 */
#define countof(arr) (sizeof(arr)/sizeof(arr[0]))

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
 * 色付きの矩形描画を行う。
 */
NS_INLINE void
CGContextFillRectWithColor(CGContextRef context, CGRect rect, CGColorRef color){
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, color);
    CGContextFillRect(context, rect);
    
    CGContextRestoreGState(context);
}

NS_INLINE void UILabelSetShadow(UILabel* label){
    label.shadowColor  = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1.0f, 1.0f);
}

/*
 * 簡単なラベルを作成し、　parentViewに追加する。
 * センター文字、背景はクリアブラックに設定。
 * fontSize 設定不要な場合は-1を渡す。
 */
NS_INLINE UILabel*
UILabelAddBasic(NSString* text, CGRect frame, CGFloat fontSize, UIView* parentView){
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    if (0 < fontSize){
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    [parentView addSubview:label];
    return label;
}

/*
 * CGPoint配列全てにアフィン変換を行う。
 */
NS_INLINE void
CGPointArrayApplyAffineTransform
(const CGPoint srcPts[], size_t count, CGPoint dstPts[], CGAffineTransform t) {
    for (int i=0; i<count; i++){
        dstPts[i] = CGPointApplyAffineTransform(srcPts[i], t);
    }
}

/*
 * CGPoint配列から、Pathを作成する。
 * コンテキストには作成したPathが設定された状態ですので、
 * CGContextAddPath関数をすぐに呼ぶ必要はありません。
 * 作成したPathはCGPathRelease関数で解放する必要があります。
 */
NS_INLINE CGPathRef
CGContextPathCreateFromPoints(CGContextRef context, CGPoint points[], size_t count){
    CGContextAddLines(context, points, count);
    CGContextClosePath(context);
    return CGContextCopyPath(context);
}


NS_INLINE void CGContextBegin(CGContextRef context) {
    CGContextSaveGState(context);
    CGContextSetShouldAntialias(context, YES);
}

NS_INLINE void CGContextEnd(CGContextRef context) {
    CGContextRestoreGState(context);
}



/*
 * バッテリステートを取得します。
 * 関数内でbatteryMonitoringEnabledをYESに設定します。
 */
NS_INLINE UIDeviceBatteryState UIDeviceBatteryGetState(){
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    return device.batteryState;
}

/*
 * UIDeviceBatteryState定数から、文字列に変換します。
 */
NS_INLINE NSString* UIDeviceBatteryStateToString(UIDeviceBatteryState state){
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
 * バッテリレベルを取得します。
 * 関数内でbatteryMonitoringEnabledをYESに設定します。
 */
NS_INLINE float UIDeviceBatteryGetLevel(){
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    return device.batteryLevel;
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
NS_INLINE void
UIDeviceBatteryRegisterStateAndLevelDidChangeNotification(id  observer,
                                                          SEL selector){
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
 * オブザーバに登録したクラスはdealloc メソッドで削除しておく。
 */
NS_INLINE void NSNotificationCenterRemoveObserver(id observer){
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

#endif // macro








/*------------------------------------------------------------------------------
  Implementation BatteryBasicView
 -----------------------------------------------------------------------------*/
#pragma mark -
@implementation BatteryBasicView
{
    // パーセンテージを表す文字列
    NSString* _levelString;

    // バッテリーの割合を表す値(無効値の場合は1.0fにしています)
    CGFloat _level;
    
    // パーセンテージ表示を行うラベル
    UILabel* _levelLabel;
    
    // バッテリーゲージ描画用のエリア矩形
    CGRect _gaugeArea;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 初期値
        _padding = 10.0f;
        
        // 背景色（デフォルトでクリアカラー）
        self.backgroundColor = [UIColor clearColor];
        
        // パーセンテージ表示用のラベル追加
        _levelLabel = UILabelAddBasic(@"", CGRectNull, 0, self);
        _levelLabel.textAlignment   = NSTextAlignmentRight;
        _levelLabel.backgroundColor = [UIColor clearColor];
        _levelLabel.textColor       = [UIColor whiteColor];
        UILabelSetShadow(_levelLabel);
        
        
        // バッテリー通知の登録
        UIDeviceBatteryRegisterStateAndLevelDidChangeNotification
        (self, @selector(update));

        // 初回更新
        [self update];
    }
    return self;
}

- (void)dealloc
{
    // バッテリー通知登録の抹消
    NSNotificationCenterRemoveObserver(self);
}


- (void)update
{
    // バッテリーレベル取得
    float fLevel = UIDeviceBatteryGetLevel();
    
    //　メンバー変数更新
    _level = (fLevel<0.0f)? 1.0f : fLevel;
    
    // パーセンテージ文字列の更新
    if (fLevel > 0.0f){
        _levelString = [NSString stringWithFormat:@"%3d%%", (int)(fLevel*100.0f)];
    }
    else {
        _levelString = @"---%";
    }
    
    // パーセンテージ表示用ラベルの更新
    _levelLabel.text = _levelString;
    
    // 描画要請
    [self setNeedsDisplay];
}

/*
 * paddingプロパティーのsetter
 */
- (void)setPadding:(CGFloat)padding {
    if (_padding != padding){
        _padding = padding;
        [self setNeedsLayout];
    }
}

@end


/*------------------------------------------------------------------------------
 Layout methods
 -----------------------------------------------------------------------------*/
@implementation BatteryBasicView(Layout)

- (void)layoutSubviews {
    
    // パーセンテージ表示用のラベル配置
    CGRect levelRect  = [self levelAreaCalcRect];
    _levelLabel.frame = levelRect;
    _levelLabel.font  = [UIFont systemFontOfSize:levelRect.size.height];
    
    
    // ゲージ描画用のレイアウト算出
    _gaugeArea = [self gaugeAreaCalcRect];
}


/*
 * パッテリーレベルのパーセント表示用の領域矩形の算出
 */
- (CGRect)levelAreaCalcRect {
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    float level_width  = w/2.0f;
    float level_height = h - (_padding*2.0f);
    
    float level_top  = (h-level_height) /2.0f;
    float level_left = 0.0f;
    
    return CGRectMake(level_left,
                      level_top,
                      level_width,
                      level_height);
}

/*
 * パッテリーゲージの描画領域矩形の算出
 */
- (CGRect)gaugeAreaCalcRect {
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    float level_width  = w/2.0f;
    float level_height = h - (_padding*2.0f);
    
    float level_top  = (h-level_height) /2.0f;
    float level_left = level_width;
    
    return CGRectMake(level_left,
                      level_top,
                      level_width,
                      level_height);
}

@end


/*------------------------------------------------------------------------------
 Draw methods
 -----------------------------------------------------------------------------*/
@implementation BatteryBasicView(Draw)

/*
 * バッテリー枠用のポイント配列 (高さ４４pxだと、幅は88pxとなる。)
 * 描画エリアの高さでスケーリングして使用する。
 */
static const CGPoint BatteryFramePoints[] = {
    { 0.20, 0.10},
    { 1.64, 0.10},
    { 1.64, 0.30},
    { 1.80, 0.30},
    { 1.80, 0.70},
    { 1.64, 0.70},
    { 1.64, 0.90},
    { 0.20, 0.90}
};

/*
 * バッテリーゲージ用の矩形
 * 描画エリアの高さでスケーリングして使用する。
 */
static const CGRect BatteryGaugeRect = {
    {0.35, 0.25},
    {1.15, 0.50}
};



- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBatteryFrame:context rect:_gaugeArea];
    [self drawBatteryGauge:context rect:_gaugeArea];
}


/*
 * バッテリ枠の描画
 */
- (void)drawBatteryFrame:(CGContextRef)context rect:(CGRect)rect {

    const size_t     count = countof(BatteryFramePoints);
    const float line_width = 2.0f;
    
    
    CGContextBegin(context);
    
    // Pathの作成
    CGPathRef path = NULL;
    CGPoint   points[count];
    CGAffineTransform scale  = CGAffineTransformMakeScale(rect.size.height,
                                                          rect.size.height);
    CGAffineTransform trans  = CGAffineTransformMakeTranslation(rect.origin.x,
                                                                rect.origin.y);
    CGAffineTransform concat = CGAffineTransformConcat(scale, trans);
    CGPointArrayApplyAffineTransform(BatteryFramePoints,
                                     count,
                                     points,
                                     concat);
    path = CGContextPathCreateFromPoints(context, points, count);
        
    // 塗りつぶし
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.5f);
    CGContextFillPath(context);
    
    // 枠の描画
    CGContextAddPath(context, path);
    CGContextSetShadow(context, CGSizeMake(2.0f, 2.0f), 1.0f);
    CGContextSetLineWidth(context, line_width);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextStrokePath(context);
    
    // 後処理
    CGPathRelease(path);
    CGContextEnd(context);
}

/*
 * バッテリゲージの描画
 */
- (void)drawBatteryGauge:(CGContextRef)context rect:(CGRect)rect {
    CGContextBegin(context);
    
    //　スケーリング
    CGAffineTransform scale  = CGAffineTransformMakeScale(rect.size.height,
                                                          rect.size.height);
    CGAffineTransform trans  = CGAffineTransformMakeTranslation(rect.origin.x,
                                                                rect.origin.y);
    CGAffineTransform concat = CGAffineTransformConcat(scale, trans);
    CGRect gauge_rect = CGRectApplyAffineTransform(BatteryGaugeRect, concat);
    
    // 描画ゲージの割合算出
    gauge_rect.size.width *= _level;
    
    // 描画
    CGContextFillRectWithColor(context, gauge_rect, [UIColor whiteColor].CGColor);
    CGContextEnd(context);
}


@end




