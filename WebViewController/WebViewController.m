
#import "WebViewController.h"


/*
 * タップできる理想のUIサイズ
 */
#define TAPPABLE_SIZE 44

/*
 * 縦または横のサイズが44ptを確保できない場合に、一方を最小30ptで適用。
 */
#define MINIMUM_TAPPABLE_SIZE 30


/*
 * ネットワーク接続中のアイコン表示にする。
 * bVisible = true  接続中
 *            false 何も表示しない。
 */
static inline void networkActivityIndicator(BOOL bVisible){
    [UIApplication sharedApplication].networkActivityIndicatorVisible = bVisible;
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



@implementation WebViewController
{
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Toolbar
    toolbarAddToHeaderWithDone(self.view, _delegate, @selector(webViewControllerDidFinish:));
    
    // WebView
    NSURLRequest* request = [NSURLRequest requestWithURL:_url];
    
    float w = self.view.bounds.size.width;
    float h = self.view.bounds.size.height;
    _webView = [[UIWebView alloc]
                initWithFrame: CGRectMake(0,TAPPABLE_SIZE,w,h - TAPPABLE_SIZE)];
    _webView.delegate = self;
    [_webView loadRequest:request];
    
    [self.view addSubview: _webView];
}





- (void)done:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _webView.delegate = nil;
    [_webView stopLoading];
}

- (void)webViewDidStartLoad:(UIWebView*)wv
{
    networkActivityIndicator(YES);
}

- (void)webViewDidFinishLoad:(UIWebView*)wv
{
    networkActivityIndicator(NO);
}

- (void)webView:(UIWebView*)wv didFailLoadWithError:(NSError*)error
{
    networkActivityIndicator(NO);
    NSString* errorString = [error localizedDescription];
    //NSString* errorTitle = [NSString stringWithFormat:@"Error (%d)", error.code];
    alertBox(errorString);
}



@end
