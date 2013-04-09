/*******************************************************************************
  macro.h 1.5.1.12

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
 * タップできる理想のUIサイズ
 */
#define TAPPABLE_SIZE 44

/*
 * 縦または横のサイズが44ptを確保できない場合に、一方を最小30ptで適用。
 */
#define MINIMUM_TAPPABLE_SIZE 30

/*
 * システムボリュームの丁度一目盛り分の値
 */
#define SOUND_VOLUME_ONE 0.0625f




/*------------------------------------------------------------------------------
                           Application functions
 -----------------------------------------------------------------------------*/
#pragma mark Application functions

/*
 * アプリケーション名を取得する。
 */
static inline NSString* getAppName(){
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
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
 * ステータスバーの非表示にする。
 */
static inline void statusBarHidden(BOOL bHidden){
    [UIApplication sharedApplication].statusBarHidden = bHidden;
}

/*
 * ネットワーク接続中のアイコン表示にする。
 * bVisible = true  接続中
 *            false 何も表示しない。
 */
static inline void networkActivityIndicator(BOOL bVisible){
    [UIApplication sharedApplication].networkActivityIndicatorVisible = bVisible;
}



/*
 * AppDelegateクラスにViewControllerを設置する
 * 下記ハンドラで使用する
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 */
static inline BOOL
rootViewControllerSetup(UIResponder<UIApplicationDelegate>* appDelegate,
                        UIViewController*                   viewController){
    
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [appDelegate.window setRootViewController:viewController];
    [appDelegate.window makeKeyAndVisible];
    return YES;
}



/*------------------------------------------------------------------------------
                             File IO functions
 -----------------------------------------------------------------------------*/
#pragma mark  File IO functions


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
 * モジュールディレクトリを取得する。
 */
static inline NSString* getModulePath(){
    return [[NSBundle mainBundle] resourcePath];
}




/*------------------------------------------------------------------------------
                           Network functions
 -----------------------------------------------------------------------------*/
#pragma mark  Network functions


/*
 * 指定のURLをリクエストし、NSDataオブジェクトを取得する。
 */
static inline NSData* dataRequestWithURL(NSString* urlString){
    // URL
    NSURL* url = [NSURL URLWithString:urlString];
    
    // GET Request
    NSURLRequest*  request  = [NSURLRequest requestWithURL:url];
    NSURLResponse* response = nil;
    NSError*       error    = nil;
    NSData*        data     = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
    return data;
}


/*
 * 指定のURLでリクエストする。
 * 取得した内容は文字列として返す。
 */
static inline NSString* stringRequestWithURL(NSString* urlString){
    NSData* data = dataRequestWithURL(urlString);
    
    // To string
    NSString* content = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    return content;
}


/*
 * 指定のURLでリクエストする。
 * 取得した内容は文字列として返す。
 */
static inline NSDictionary* jsonRequestWithURL(NSString* urlString){
    NSData*   data = dataRequestWithURL(urlString);
    NSError* error = nil;
    
    // To Dictionary
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:&error];
    
    return dict;
}

/*
 * URLエンコードする
 */
static inline NSString* stringEncode(NSString* str){
    CFStringRef encodedString =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)str,
                                            NULL,
                                            CFSTR(";,/?:@&=+$#"),
                                            kCFStringEncodingUTF8);
    
    NSString* nsString = [NSString stringWithString:(__bridge NSString*)encodedString];
    CFRelease(encodedString);
    return nsString;
}



/*------------------------------------------------------------------------------
                              Chrono functions
 -----------------------------------------------------------------------------*/
#pragma mark  Chrono functions

/*
 * 日付をYYYYMMDD形式の文字列に変換する。
 */
static inline NSString* dateFormatToYYYYMMDD(NSDate* date){
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMMdd";
    return [formatter stringFromDate:date];
}


/*
 * 日付をHH:mm形式の文字列に変換する。
 */
static inline NSString* dateFormatToHHmm(NSDate* date){
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:date];
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
 * 繰り返しタイマーをセットする。
 * - (void)tick:(NSTimer*)sender
 */
static inline void scheduledTimer(double interval, id target, SEL action){
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:target
                                   selector:action
                                   userInfo:nil
                                    repeats:YES];
}



/*------------------------------------------------------------------------------
                               View functions
 -----------------------------------------------------------------------------*/
#pragma mark View functions

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
 * ビューコントローラを登場させる。
 */
static inline void
presentViewController(UIViewController* currentViewController,
                      UIViewController* newViewController)
{
    [currentViewController presentViewController:newViewController
                                        animated:YES
                                      completion:NULL];
}

/*
 * ビューコントローラをどける。
 */
static inline void dismissViewController(UIViewController* viewController){
    [viewController dismissViewControllerAnimated:YES completion:NULL];
}


/*
 * ビューのヘッダ部にUIToolbarを追加します。
 */
static inline UIToolbar* toolbarAddToHeader(UIView* parentView){
    float w = parentView.bounds.size.width;
    CGRect rect = CGRectMake(0,0, w, TAPPABLE_SIZE);
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:rect];
    [parentView addSubview:toolbar];
    return toolbar;
}

/*
 * ビューのヘッダ部にDoneボタンを持ったUIToolbarを追加します。
 */
static inline UIToolbar* toolbarAddToHeaderWithDone(UIView* parentView, id target, SEL action){
    UIToolbar* toolbar = toolbarAddToHeader(parentView);
    
    UIBarButtonItem* buttonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:target
                                                  action:action];
    NSArray* items = [NSArray arrayWithObjects:buttonItem, nil];
    [toolbar setItems:items animated:YES];
    
    return toolbar;
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
 * UIViewControllerの親子関係を作る。
 */
static inline void
addChildViewController(UIViewController* child, UIViewController* toParent){
    [toParent addChildViewController:child];
    [toParent.view addSubview:child.view];
    [child didMoveToParentViewController:toParent];
}

/*
 * ビューのスケールを設定する。
 */
static inline void viewSetScale(UIView* view, CGFloat scale){
    view.transform = CGAffineTransformMakeScale(scale, scale);
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
 * UIImageのinitWithContentsOfFileメソッドで読み込んだイメージは描画時にデコード処理が入るようになる為、
 * 描画速度が遅くなる。この関数で読み込めばその問題が解消できる。
 */
static inline UIImage*
imageImmediateLoadWithContentsOfFile(NSString* path){
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
 * UIImageViewをparentViewに追加する。 サイズはフィットするように配置される。
 * 成功時には作成したUIImageViewのオブジェクトが返る。
 */
static inline UIImageView*
imageAddBasicFromPath(NSString* imagePath, UIView* parentView){
    UIImage* image = imageImmediateLoadWithContentsOfFile(imagePath);
    if (nil == image) {
        dmsg(@"イメージの読み込みに失敗しました。");
        return nil;
    }
    return imageViewAddToParent(image, parentView);
}


/*
 * 簡易なUIButtonをparentViewに追加する。
 * イベントも追加する。
 * デリゲート例)
 * - (void)buttonTaped:(UIButton*)sender
 */
static inline UIButton*
buttonAddBasic(NSString* title, CGRect frame, UIView* parentView, id target, SEL action){
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = frame;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:button];
    return button;
}


/*
 * リソース画像からCustomButtonをparentViewに追加する。
 */
static inline UIButton*
buttonAddCustum(NSString* imageNameForNormal, NSString* imageNameForHighlighted,
                CGRect frame, UIView* parentView, id target, SEL action){
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:imageNameForNormal]
            forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageNameForHighlighted]
            forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    
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





/*------------------------------------------------------------------------------
                              Other functions
 -----------------------------------------------------------------------------*/
#pragma mark Other functions


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
 * UUID文字列を生成する
 */
static inline NSString* UUIDGenerate(){
    CFUUIDRef   uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    
    NSString* fileName = [NSString stringWithString:(__bridge NSString*)uuidStr];
    CFRelease(uuidStr);
    return fileName;
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
 * 角丸四角形を描画する
 */
static inline void
drawRoundRect(CGContextRef context, CGRect rect, CGFloat radius, CGColorRef color){
    
    CGContextSetFillColorWithColor(context, color);
    
    float left  = rect.origin.x;
    float top   = rect.origin.y;
    float right = left + rect.size.width;
    float bottom= top  + rect.size.height;
    
    CGContextMoveToPoint(context, left, top + (rect.size.height/2));
    CGContextAddArcToPoint(context,  left,    top, right,    top, radius);
    CGContextAddArcToPoint(context, right,    top, right, bottom, radius);
    CGContextAddArcToPoint(context, right, bottom,  left, bottom, radius);
    CGContextAddArcToPoint(context,  left, bottom,  left,    top, radius);
    CGContextClosePath(context);
    CGContextFillPath(context);
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

/*
 * 今の音量から増減量を指定する。0-1
 */
static inline void systemAddVolume(float addVolume){
    MPMusicPlayerController* musicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume += addVolume;
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
