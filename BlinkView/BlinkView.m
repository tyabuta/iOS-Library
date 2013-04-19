
#import "BlinkView.h"


#pragma mark -
#pragma mark Macros

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




#pragma mark -
#pragma Implementation BlinkView

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




#pragma mark Methods

- (void)stopBlink {
    if (_timer){
        NSTimerStop(_timer);
    }
    _timer = nil;
    self.hidden = YES;
}

- (void)startBlink {
    if (nil == _timer){
        _timer = NSTimerStart(0.1f, self, @selector(tick:));
    }
}


@end














