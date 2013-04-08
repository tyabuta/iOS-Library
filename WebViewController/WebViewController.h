/*******************************************************************************

                          WebViewController 1.0.0.1
 
                                                            (c) 2013 tyabuta.
 ******************************************************************************/


#import <UIKit/UIKit.h>

@protocol WebViewControllerDelegate;


@interface WebViewController:
UIViewController<UIWebViewDelegate, UIWebViewDelegate>
@property(nonatomic,assign) id<WebViewControllerDelegate> delegate;

- (id)initWithURL:(NSURL*)url;

@end


@protocol WebViewControllerDelegate <NSObject>
- (void)webViewControllerDidFinish:(WebViewController*)webViewController;
@end

