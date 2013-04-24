
#import "BlinkView.h"


/*------------------------------------------------------------------------------
 Macro funcitons
 -----------------------------------------------------------------------------*/
#pragma mark - Macro functions

/*
 * 繰り返しタイマーをセットする。
 * - (void)tick:(NSTimer*)timer
 */
NS_INLINE NSTimer* NSTimerStart(double interval, id target, SEL action){
    NSTimer* timer =
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:target
                                   selector:action
                                   userInfo:nil
                                    repeats:YES];
    return timer;
}

/*
 * タイマーを停止させる。
 */
NS_INLINE void NSTimerStop(NSTimer* timer){
    [timer invalidate];
}




/*------------------------------------------------------------------------------
 Implementation BlinkView
 -----------------------------------------------------------------------------*/
#pragma mark - Implementation BlinkView

@implementation BlinkView {
    NSTimer* _timer;
}

- (id)initWithImage:(UIImage*)image frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_imageView];
        // アスペクト比が崩れないように親ビューにフィットさせる。
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithImage:nil frame:frame];
}

- (void)layoutSubviews{
    _imageView.frame = self.bounds;
}

- (void)tick:(NSTimer*)timer{
    self.hidden = !self.hidden;    
}

/*
 * intervalプロパティのセッター
 */
- (void)setInterval:(CGFloat)interval {
    
    // インターバルに変更があれば、更新する。
    if (_interval != interval){
        _interval = interval;
        
        // 点滅中であれば、一旦停止して再稼働させる。
        if ([self isBlink]){
            [self stopBlink];
            [self startBlink];
        }
    }
}
@end




/*------------------------------------------------------------------------------
 Action methods
 -----------------------------------------------------------------------------*/
@implementation BlinkView(Action)

/*
 * 点滅を開始する、点滅の間隔についてはintervalプロパティで設定する。
 */
- (void)startBlink {
    if (nil == _timer){
        _timer = NSTimerStart(_interval, self, @selector(tick:));
    }
}

/*
 * 点滅を停止し、ビュー表示を消す。
 */
- (void)stopBlink {
    if (_timer){
        NSTimerStop(_timer);
    }
    _timer = nil;
    self.hidden = YES;
}

@end



/*------------------------------------------------------------------------------
 Property methods
 -----------------------------------------------------------------------------*/
@implementation BlinkView(Property)
/*
 * 点滅中か調べる。
 */
- (BOOL)isBlink{
    return (nil != _timer);
}


@end


