
#import "SoundGaugeView.h"
#import <MediaPlayer/MediaPlayer.h>

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


/*
 * 簡易なUISliderをparentViewに追加する。
 * イベントも追加する。
 * - (void)sliderValueChanged:(UISlider*)sender
 */
static inline UISlider*
sliderAddBasic(CGRect frame, UIView* parentView, id target, SEL action){
    UISlider* slider = [[UISlider alloc] initWithFrame:frame];
    [slider addTarget:target
               action:action
     forControlEvents:UIControlEventValueChanged];
    [parentView addSubview:slider];
    return slider;
}

/*
 * 音量を設定する。0-1
 */
static inline void systemSetVolume(float volume){
    MPMusicPlayerController* musicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = volume;
}

/*
 * 今の音量を取得する。0-1
 */
static inline float systemGetVolume(){
    MPMusicPlayerController* musicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    return musicPlayer.volume;
}










@implementation SoundGaugeView
{
    UIImageView* _imageView;
    UISlider*    _sliderView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Sound Image
        _imageView = imageAddBasicFromResource(@"sound.png", self);
        
        // Slider
        float w = self.bounds.size.width;
        _sliderView = sliderAddBasic(CGRectMake(50, 10, w - 60, 44),
                                          self,
                                          self,
                                          @selector(sliderValueChanged:));
        float vol = systemGetVolume();
        _sliderView.value = vol;
        [self addSubview:_sliderView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)sliderValueChanged:(UISlider*)slider
{
    systemSetVolume(slider.value);
}

- (void)layoutSubviews{
    _imageView.frame = CGRectMake(10, 15, 32,32);

    float w = self.bounds.size.width;
    _sliderView.frame = CGRectMake(50, 10, w - 60, 44);
}

@end
