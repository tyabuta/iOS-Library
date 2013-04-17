
#import "SoundGaugeView.h"
#import <MediaPlayer/MediaPlayer.h>



#pragma mark -
#pragma mark Macros

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
 * タップできる理想のUIサイズ
 */
#define TAPPABLE_SIZE 44.0f


/*
 * CGFloat同士がイコールか比較を行う。
 * kVerySmallValue:  最小精度を指定する。
 * 例）0.01f -> 0.01fより差があれば同じとは判断しない。
 */
static inline BOOL
CGFloatIsEqual(CGFloat f1, CGFloat f2, CGFloat kVerySmallValue){
    return !(fabsf(f1 - f2) > kVerySmallValue);
}

/*
 * 指定イメージから切り抜いたUIImageを取得する。
 */
static inline UIImage*
UIImageCreateWithImageInRect(UIImage* sourceImage, CGRect inRect){
    UIImage*       image = nil;
    CGImageRef image_ref =
    CGImageCreateWithImageInRect(sourceImage.CGImage, inRect);
    
    image = [UIImage imageWithCGImage:image_ref
                                scale:1.0f
                          orientation:UIImageOrientationUp];
    
    CGImageRelease(image_ref);
    return image;
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
 * 通知センターに登録したオブザーバを削除する。
 * オブザーバに登録したクラスはdealloc メソッドで削除しておく。
 */
static inline void NSNotificationCenterRemoveObserver(id observer){
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}




/*
 * #import <MediaPlayer/MediaPlayer.h>
 * MediaPlayer.frameworkが必要
 */
#ifdef MP_EXTERN_CLASS_AVAILABLE

/*
 * 音量を設定する。0-1
 */
static inline void MPMusicPlayerControllerSetVolume(float volume){
    MPMusicPlayerController* musicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = volume;
}

/*
 * 今の音量を取得する。0-1
 */
static inline float MPMusicPlayerControllerGetVolume(){
    MPMusicPlayerController* musicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    return musicPlayer.volume;
}



/*
 * MusicPlayerの通知発行を有効にする。
 * 通知の必要がなくなったら、無効にしましょう。
 * bBegin: YES->有効 NO->無効
 */
static inline void
MPMusicPlayerControllerGeneratingPlaybackNotifications(BOOL bBegin){
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    if (bBegin){
        [musicPlayer beginGeneratingPlaybackNotifications];
    }
    else {
        [musicPlayer endGeneratingPlaybackNotifications];
    }
}

/*
 * システムボリュームの変更通知のオブザーバとセレクタを登録する。
 * - (void)func:(NSNotification *)notification
 *
 * notification.name プロパティでどの通知が発生したのかがわかる。
 * MPMusicPlayerControllerVolumeDidChangeNotification
 *
 * 通知の必要がなくなったら、NSNotificationCenterRemoveObserver関数で
 * オブサーバー登録を抹消しましょう。
 *
 * 通知発行も必要ないなら、
 * MPMusicPlayerControllerGeneratingPlaybackNotifications関数で通知発行を停止しましょう。
 */
static inline void
MPMusicPlayerControllerRegisterVolumeDidChangeNotification(id observer, SEL selector){
    
    // 通知センターへ登録
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:observer
               selector:selector
                   name:MPMusicPlayerControllerVolumeDidChangeNotification
                 object:nil];
    
    // 通知発行を有効にする。
    MPMusicPlayerControllerGeneratingPlaybackNotifications(YES);
}

#endif // MP_EXTERN_CLASS_AVAILABLE



















/* -----------------------------------------------------------------------------
 * Implementation SoundGaugeView
 -----------------------------------------------------------------------------*/
#pragma mark -
#pragma mark Implementation SoundGaugeView

// アイコン一つあたりのサイズ(px)
#define ICON_SIZE      64.0f

// アイコン画像の連結個数
#define NUMBER_OF_ICON 4

// アイコンリソースの名前
static NSString* const ICON_RESOURCE_NAME = @"SoundIcons.png";


@implementation SoundGaugeView
{
    UISlider*    _slider;                 // ボリュームコントロール用のスライダー
    UIImageView* _imageView;              // アイコン表示用のUiImageView
    UIImage*     _images[NUMBER_OF_ICON]; // アイコン画像の配列
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 背景は初期設定でクリアカラー
        self.backgroundColor = [UIColor clearColor];
        
        // アイコンイメージの読み込み
        UIImage* sourceImage = [UIImage imageNamed:ICON_RESOURCE_NAME];
        for (int i=0; i<NUMBER_OF_ICON; i++) {
            CGRect inRect = CGRectMake(i*ICON_SIZE, 0, ICON_SIZE, ICON_SIZE);
            _images[i] = UIImageCreateWithImageInRect(sourceImage, inRect);
        }
        
        // アイコンイメージをUIImageViewに設定
        _imageView = imageViewAddToParent(_images[0], self);
        
        // スライダー
        _slider = sliderAddBasic(CGRectNull,
                                 self,
                                 self,
                                 @selector(sliderValueChanged:));
    
        // システムボリュームの変更通知登録
        MPMusicPlayerControllerRegisterVolumeDidChangeNotification
        (self, @selector(volumeDidChange:));
        
        // 初回更新
        [self update];
    }
    return self;
}

- (void)dealloc{
    // 通知発行の停止
    MPMusicPlayerControllerGeneratingPlaybackNotifications(NO);
    // オブザーバーの登録抹消
    NSNotificationCenterRemoveObserver(self);
}

- (void)layoutSubviews{
    float h = self.bounds.size.height;
    float w = self.bounds.size.width;

    // アイコン用のUIImageView配置
    const float kMargin = 5.0f;
    const float kImageViewSize = 32.0f;
    _imageView.frame = CGRectMake(kMargin,
                                  (h - kImageViewSize)/2.0f,
                                  kImageViewSize,
                                  kImageViewSize);

    // スライダー配置
    const float kSliderLeft = kMargin + kImageViewSize + kMargin;
    _slider.frame = CGRectMake(kSliderLeft,
                               (h-TAPPABLE_SIZE)/2.0f,
                               w - kSliderLeft - kMargin,
                               TAPPABLE_SIZE);
}

- (void)update {    
    float fVolume = MPMusicPlayerControllerGetVolume();
    int   nVolume = (int)(fVolume * 100.0f);

    // スライダーの値更新
    if (NO == CGFloatIsEqual(fVolume, _slider.value, 0.001f)){
        _slider.value = fVolume;
    }
    
    // サウンドアイコンの更新
    static int prev_index = -1;
    int index = 0;
    if      (0 == nVolume){ index = 0; }
    else if (30 > nVolume){ index = 1; }
    else if (80 > nVolume){ index = 2; }
    else                  { index = 3; }
    if (prev_index != index){
        _imageView.image = _images[index];
        prev_index = index;
    }
    
}


#pragma mark Events

/*
 * システムボリュームの変更イベント
 */
- (void)volumeDidChange:(NSNotification *)notification {
    [self update];
}

/*
 * スライダーの変更イベント
 */
- (void)sliderValueChanged:(UISlider*)slider {
    MPMusicPlayerControllerSetVolume(slider.value);
    [self update];
}

@end // SoundGaugeView





