/*******************************************************************************
  macro.h 1.4.0.5

                              マクロ関数用のヘッダ
 
                                                             (c) 2013 tyabuta.
*******************************************************************************/

#ifndef TYABUTA_IOS_MACRO_H
#define TYABUTA_IOS_MACRO_H


#import <UIKit/UIKit.h>


/*
 * class_getName関数を使用する為のインポート
 * 実行環境によってヘッダファイルが異なる為、プリプロセッサにより条件分岐させている。
 */
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#endif


/*
 * gettimeofday関数を使用する為に必要なインポート。
 */
#import <sys/time.h>




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
 * class_getName関数を使用して、クラス名を取得する。
 */
static inline NSString* getClassName(id object){
    return [NSString stringWithUTF8String: class_getName([object class])];
}



/*
 * CGSize構造体用の文字列を生成する。
 */
static inline NSString* CGSizeToString(CGSize size){
    return [NSString stringWithFormat: @"%fx%f", size.width, size.height ];
}

/*
 * CGPoint構造体用の文字列を生成する。
 */
static inline NSString* CGPointToString(CGPoint point){
    return [NSString stringWithFormat: @"%f,%f", point.x, point.y];
}

/*
 * CGRect構造体用の文字列を生成する。
 */
static inline NSString* CGRectToString(CGRect rect){
    return [NSString stringWithFormat: @"%f,%f %fx%f",
            rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}


/*
 * dumpSubView関数内部で呼ばれる内部関数
 */
static NSString* _dumpSubview(UIView* view, int indent){
    
    NSString* strIndent = @"";
    for (int i=0; i<indent; i++){
        if (i==indent-1) {
            strIndent = [strIndent stringByAppendingString:@"+---"];
        }
        else {
            strIndent = [strIndent stringByAppendingString:@"|   "];
        }
    }
    
    NSString* str = [NSString stringWithFormat:@"%@%s\n",
                     strIndent,
                     class_getName([view class])];
    
    for (UIView* subView in view.subviews){
        NSString* ret = _dumpSubview(subView, indent+1);
        str = [str stringByAppendingString:ret];
    }
    return str;
}


/*
 * UIViewのSubViewを階層表示した文字列を返す。
 */
static inline NSString* dumpSubview(UIView* view){
    return _dumpSubview(view, 0);
}


/*
 * 現在の時間[sec]をmicrosecondの精度で取得する。
 */
static inline double gettime(){
    struct timeval t;
    gettimeofday(&t, NULL);
    return t.tv_sec + (t.tv_usec * 1e-6);
}


/*
 * アプリケーション名を取得する。
 */
static inline NSString* getAppName(){
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}



/*
 * モジュールディレクトリを取得する。
 */
static inline NSString* getModulePath(){
    return [[NSBundle mainBundle] resourcePath];
}

/*
 * PATHをスラッシュでつなげる。
 */
static inline NSString* joinPath(NSString* dir, NSString* file){
    return [NSString stringWithFormat:@"%@/%@", dir, file];
}

/*
 * PATHからファイル名のみ取り出す。
 */
static inline NSString* getFileNameFromPath(NSString* path){
    return [path lastPathComponent];
}

/*
 * UIRecogenizerのタッチイベントから、座標を取得する。
 * view: 基準座標となるビュー
 */
static inline CGPoint getTouchPoint(NSSet* touches, UIView* view){
    UITouch* touch = [touches anyObject];
    return [touch locationInView:view];
}

/*
 * 半透明の黒色
 */
static inline UIColor* clearBlack(){
    return [UIColor colorWithWhite:0.0f alpha:0.5f];
}

/*
 * 半透明の白色
 */
static inline UIColor* clearWhite(){
    return [UIColor colorWithWhite:1.0f alpha:0.3f];
}

/*
 * 日付をYYYYMMDD形式の文字列に変換する。
 */
static inline NSString* dateFormatToYYYYMMDD(NSDate* date){
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMMdd";
    return [formatter stringFromDate:date];
}

/*
 * 数値文字列を整数値に変換する。
 */
static inline int strToInt(NSString* str){
    return [str integerValue];
}

/*
 * システムフォントを取得する。
 */
static inline UIFont* systemFontOfSize(CGFloat size){
    return [UIFont systemFontOfSize:size];
}

/*
 * ビューのスケールを設定する。
 */
static inline void viewSetScale(UIView* view, CGFloat scale){
    view.transform = CGAffineTransformMakeScale(scale, scale);
}


/*
 * UserDefaultsに文字列を保存する。
 */
static inline void setDefaultString(NSString* str, NSString* forKey){
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:str forKey:forKey];
    [userDefaults synchronize];
}

/*
 * UserDefaultsに数値を保存する。
 */
static inline void setDefaultInteger(NSInteger intValue, NSString* forKey){
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:intValue forKey:forKey];
    [userDefaults synchronize];
}

/*
 * UserDefaultsに小数値を保存する。
 */
static inline void setDefaultFloat(float floatValue, NSString* forKey){
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:floatValue forKey:forKey];
    [userDefaults synchronize];
}

/*
 * UserDefaultsに小数値を保存する。
 */
static inline void removeDefaultKey(float floatValue, NSString* forKey){
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:forKey];
    [userDefaults synchronize];
}

/*
 * UserDefaultsから文字列を取得する。
 */
static inline NSString* getDefaultString(NSString* key){
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

/*
 * UserDefaultsから数値を取得する。
 */
static inline NSInteger getDefaultInteger(NSString* key){
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

/*
 * UserDefaultsから数値を取得する。
 */
static inline float getDefaultFloat(NSString* key){
    return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}


/*
 * UserDefaultsの全ての値を取得する。
 */
static inline NSString* dumpAllDefaults(){
    NSDictionary* dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    return [NSString stringWithFormat:@"defualts:%@", dic];
}

/*
 * UserDefaultsのアプリケーション固有の値を取得する。
 */
static inline NSString* dumpAppDefaults(){
    NSString*      appDomain = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary*  dic       = [[NSUserDefaults standardUserDefaults] persistentDomainForName:appDomain];
    return [NSString stringWithFormat:@"defualts:%@", dic];
}





/*
 * UIImageのinitWithContentsOfFileメソッドで読み込んだイメージは描画時にデコード処理が入るようになる為、
 * 描画速度が遅くなる。この関数で読み込めばその問題が解消できる。
 */
static UIImage* imageImmediateLoadWithContentsOfFile(NSString* path){
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    CGImageRef imageRef = [image CGImage];
    CGRect rect = CGRectMake(0.f, 0.f, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       rect.size.width,
                                                       rect.size.height,
                                                       CGImageGetBitsPerComponent(imageRef),
                                                       CGImageGetBytesPerRow(imageRef),
                                                       CGImageGetColorSpace(imageRef),
                                                       CGImageGetBitmapInfo(imageRef)
                                                       );
    CGContextDrawImage(bitmapContext, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef];
    CGImageRelease(decompressedImageRef);
    CGContextRelease(bitmapContext);
    
    return decompressedImage;
}


/*
 * モジュールディレクトリから指定ディレクトリのファイル一覧のPATH配列を取得する。
 */
static NSArray* getFilePathsFromResource(NSString* dir){
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString* rootDir      = [NSString stringWithFormat:@"%@/%@", resourcePath, dir];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* fileArray = [fileManager contentsOfDirectoryAtPath: rootDir error:nil];
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for (NSString* file in fileArray) {
        [arr addObject: [NSString stringWithFormat:@"%@/%@", rootDir, file]];
    }
    
    return [NSArray arrayWithArray:arr];
}

/*
 * 指定のサイズに丁度フィットするCGRectを計算する。
 */
static CGRect rectToFit(CGSize size, CGSize contentSize){
    // 縮小率を計算する
    CGFloat max_w = contentSize.width;
    CGFloat max_h = contentSize.height;
    CGFloat wk = max_w / size.width;
    CGFloat hk = max_h / size.height;
    CGFloat k=(wk>hk)? hk:wk;
    
    // リサイズ後のサイズ
    CGFloat new_w = size.width * k;
    CGFloat new_h = size.height* k;
    CGFloat left = (max_w - new_w) / 2;
    CGFloat top  = (max_h - new_h) / 2;
    
    return CGRectMake(left, top, new_w, new_h);
}

/*
 * 簡単なアラートメッセージを表示する。
 */
static void alertBox(NSString* msg){
    NSString*    productName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    UIAlertView* alert       = [[UIAlertView alloc]
                                initWithTitle:productName
                                message:msg
                                delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"OK", nil];
    [alert show];
}


/*
 * UIImageViewをparentViewに追加する。 サイズはフィットするように配置される。
 * 成功時には作成したUIImageViewのオブジェクトが返る。
 */
static UIImageView* imageAddBasicFromResource(NSString* imageName, UIView* parentView)
{
    UIImage* image = [UIImage imageNamed:imageName];
    if (nil == image) {
        NSLog(@"イメージの読み込みに失敗しました。　%s, %d", __FILE__, __LINE__);
        return nil;
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    CGRect rect = rectToFit(image.size, parentView.frame.size);
    [imageView setFrame:rect];
    [parentView addSubview:imageView];
    return imageView;
}

/*
 * UIImageViewをparentViewに追加する。 サイズはフィットするように配置される。
 * 成功時には作成したUIImageViewのオブジェクトが返る。
 */
static UIImageView* imageAddBasicFromPath(NSString* imagePath, UIView* parentView)
{
    UIImage* image = imageImmediateLoadWithContentsOfFile(imagePath);
    if (nil == image) {
        NSLog(@"イメージの読み込みに失敗しました。　%s, %d", __FILE__, __LINE__);
        return nil;
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    // アスペクト比が崩れないように親ビューにフィットさせる。
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = parentView.bounds;
    [parentView addSubview:imageView];
    return imageView;
}


/*
 * 簡易なUIButtonをparentViewに追加する。
 * イベントも追加する。
 * デリゲート例)
 * - (void)buttonTaped:(UIButton*)sender
 */
static UIButton* buttonAddBasic(NSString* title, CGRect frame, UIView* parentView, id target, SEL action){
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = frame;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:button];
    return button;
}


/*
 * 簡単なラベルを作成し、　parentViewに追加する。
 * センター文字、背景はクリアブラックに設定。
 * fontSize 設定不要な場合は-1を渡す。
 */
static UILabel* labelAddBasic(NSString* text, CGRect frame, CGFloat fontSize, UIView* parentView){
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
 * ヘッダー用のラベルを追加する。
 */
static UILabel* labelAddHeader(NSString* caption, UIView* parentView){
    UILabel* header = [[UILabel alloc] init];
    header.text = caption;
    header.textColor = [UIColor whiteColor];
    header.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    header.textAlignment = NSTextAlignmentCenter;
    header.frame = CGRectMake(0, 0, parentView.bounds.size.width, 30);
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [parentView addSubview:header];
    return header;
}

/*
 * ヘッダ用のラベルを追加する。
 */
static UILabel* labelAddFooter(NSString* caption, UIView* parentView){
    const CGFloat height = 30.0f;
    
    UILabel* header = [[UILabel alloc] init];
    header.text = caption;
    header.textColor = [UIColor whiteColor];
    header.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    header.textAlignment = NSTextAlignmentCenter;
    header.frame = CGRectMake(0,
                              parentView.bounds.size.width - height,
                              parentView.bounds.size.width,
                              height);
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [parentView addSubview:header];
    return header;
}




/*
 * 簡単なテキストフィールドを作成し、　parentViewに追加する。
 * センター文字に設定。
 * fontSize 設定不要な場合は-1を渡す。
 */
static UITextField* textFieldAddBasic(CGRect frame, CGFloat fontSize, UIView* parentView){
    UITextField* textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle   = UITextBorderStyleRoundedRect;
    textField.textAlignment = NSTextAlignmentCenter;
    if (0 < fontSize){
        textField.font = [UIFont systemFontOfSize:fontSize];
    }
    
    [parentView addSubview:textField];
    return textField;
}


/*
 * ピンチジェスチャーを追加する。
 * - (void)viewPinched:(UIPinchGestureRecognizer*)recognizer
 */
static inline UIPinchGestureRecognizer* pinchRecognizerAddToView(UIView* view, id target, SEL action){
    UIPinchGestureRecognizer* recognizer = [[UIPinchGestureRecognizer alloc] init];
    [recognizer addTarget:target action:action];
    [view addGestureRecognizer:recognizer];
    return recognizer;
}



/*
 * バッテリステートを文字列で取得します。
 * 関数内でbatteryMonitoringEnabledをYESに設定します。
 */
static NSString* getBatteryState(){
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
static NSString* getBatteryLevel(){
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
static void registerBatteryNotificationObserver(id observer, SEL selector){
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
 * 上向きと下向きのみ、回転を許可する。
 * shouldAutorotateToInterfaceOrientationメソッドで使用してください。
 * - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 */
static inline BOOL orientationPermitForUpAndDownside(UIInterfaceOrientation interfaceOrientation){
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return YES;
        default:
            break;
    }
    return NO;
}



/*
 * UIViewControllerの親子関係を作る。
 */
static inline void
addChildViewController(UIViewController* child, UIViewController* toParent){
    [toParent addChildViewController:child];
    [toParent.view addSubview:child.view];
    [child didMoveToParentViewController:toParent];
}


/*
 * イメージピッカーを表示する。
 * viewController: プロトコルが実装されたUIViewController
 *
 * プロトコル実装
 * UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
 *
 * 画像選択後のデリゲート
 * - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
 *
 * 選択キャンセル時のデリゲート
 * - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
 *
 */
static inline void imagePickerShow(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>* viewController){
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = viewController;
    picker.allowsEditing = YES;
    [viewController presentViewController:picker animated:YES completion:NULL];
}

/*
 * イメージピッカーが選択したUIImageを取得し、ピッカー表示を消す。
 */
static inline UIImage* imagePickerGetPickedImageAndHide(UIImagePickerController* picker, NSDictionary* info){
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    return image;
}

/*
 * イメージピッカーの表示を消す。
 */
static inline void imagePickerHide(UIImagePickerController* picker){
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


/*
 * Tip: <Twitter/TWTweetComposeViewController.h>がインポートされている場合、
 *      SOCIAL_CLASS_AVAILABLE が定義される。
 */
#ifdef SOCIAL_CLASS_AVAILABLE

/*
 * TWTweetComposeViewControllerを使用して、ツイートを行う。
 * <Twitter/TWTweetComposeViewController.h>のインポートと、Twitter.frameworkが必要。
 */
static inline void tweetComposeShow(NSString* initialTweet, UIImage* image, UIViewController* viewController){
    TWTweetComposeViewController* tweet_view = [[TWTweetComposeViewController alloc] init];
    [tweet_view setInitialText:initialTweet];
    if (nil == image){ [tweet_view addImage:image]; }
    [viewController presentViewController:tweet_view animated:YES completion:NULL];
}

#endif // SOCIAL_CLASS_AVAILABLE




/*
 * #import <MediaPlayer/MediaPlayer.h>
 * MediaPlayer.frameworkが必要
 */
#ifdef MP_EXTERN_CLASS_AVAILABLE

/*
 * 音量を設定する。0-1
 */
static inline void systemVolumeSet(float volume){
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = volume;
}

/*
 * 今の音量から増減量を指定する。0-1
 */
static inline void systemVolumeAdditional(float addVolume){
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume += addVolume;
}

/*
 * 今の音量を取得する。0-1
 */
static inline float systemVolumeGet(float volume){
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    return musicPlayer.volume = volume;
}

/*
 * システムボリュームの丁度一目盛り分の値を取得する。
 */
static inline float systemVolumeOne(){
    return 0.0625f;
}
#endif // MP_EXTERN_CLASS_AVAILABLE


/*
 * #import <QuartzCore/QuartzCore.h>
 */
#ifdef QUARTZCORE_H

/*
 * ビューのコーナに丸くマスクをかける。
 */
static inline void viewSetCornerRadiusAndMask(UIView* view){
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
}

#endif // QUARTZCORE_H




#endif // TYABUTA_IOS_MACRO_H
// EOF