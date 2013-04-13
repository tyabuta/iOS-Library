
#import "WebViewController.h"


/*
 * タップできる理想のUIサイズ
 */
#define TAPPABLE_SIZE 44

/*
 * 縦または横のサイズが44ptを確保できない場合に、一方を最小30ptで適用。
 */
#define MINIMUM_TAPPABLE_SIZE 30




#pragma mark -
#pragma mark Macro functions

/*
 * ネットワーク接続中のアイコン表示にする。
 * bVisible = true  接続中
 *            false 何も表示しない。
 */
static inline void networkActivityIndicator(BOOL bVisible){
    [UIApplication sharedApplication].networkActivityIndicatorVisible = bVisible;
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
 * デバイス向きを考慮した、適切なスクリーンサイズを取得する。
 * (ステータスバーの幅を引いた値)
 */
static inline CGSize
UIInterfaceOrientationConsideredScreenSize(UIInterfaceOrientation interfaceOrientation){
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return UIInterfaceOrientationIsPortrait(interfaceOrientation)?
    screenSize : CGSizeMake(screenSize.height, screenSize.width);
}





#pragma mark -
#pragma mark WebViewController implementation

@implementation WebViewController
{
    UIToolbar* _toolbar;
    UIWebView* _webView;
    NSURL*     _url;
}

- (id)initWithURL:(NSURL*)url
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _url = url;
        
    }
    return self;
}

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}





#pragma mark ViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 回転向きを考慮したスクリーンサイズを取得
    CGSize screenSize = UIInterfaceOrientationConsideredScreenSize(self.interfaceOrientation);
    float w = screenSize.width;
    float h = screenSize.height;

    // Toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,
                                                           screenSize.width,
                                                           TAPPABLE_SIZE)];
    [self.view addSubview:_toolbar];
    UIBarButtonItem* buttonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:_delegate
                                                  action:@selector(webViewControllerDidFinish:)];
    NSArray* items = [NSArray arrayWithObjects:buttonItem, nil];
    [_toolbar setItems:items animated:YES];

    
    // WebView
    NSURLRequest* request = [NSURLRequest requestWithURL:_url];
    
    _webView = [[UIWebView alloc]
                initWithFrame: CGRectMake(0,TAPPABLE_SIZE,w,h - TAPPABLE_SIZE)];
    _webView.delegate = self;
    [_webView loadRequest:request];
    
    [self.view addSubview: _webView];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    // 回転向きを考慮したスクリーンサイズを取得
    CGSize screenSize = UIInterfaceOrientationConsideredScreenSize(toInterfaceOrientation);

    // ツールバーの配置
    _toolbar.frame = CGRectMake(0, 0, screenSize.width, TAPPABLE_SIZE);
    
    // WebViewの配置
    _webView.frame = CGRectMake(0,
                                TAPPABLE_SIZE,
                                screenSize.width,
                                screenSize.height - TAPPABLE_SIZE);
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _webView.delegate = nil;
    [_webView stopLoading];
}








#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    networkActivityIndicator(NO);
    NSString* errorString = [error localizedDescription];
    //NSString* errorTitle = [NSString stringWithFormat:@"Error (%d)", error.code];
    alertBox(errorString);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    networkActivityIndicator(YES);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    networkActivityIndicator(NO);
}

@end
