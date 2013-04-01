#import "SoundVolumeController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>



#define CONTROLLER_WIDTH  100
#define CONTROLLER_HEIGHT 150

#define BUTTON_WIDTH  80
#define BUTTON_HEIGHT 40

#define A_VOLUME 0.0625f // メモリ一つ分の変化量

#define SOUND_ID_FOR_LIMIT  1104
#define SOUND_ID_FOR_VOLUME 1057

@implementation SoundVolumeController
{
    UIButton* upButton;
    UIButton* downButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 自身のビュー設定
    self.view.layer.cornerRadius = 5.0f;
    self.view.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    self.view.bounds = CGRectMake(0, 0, CONTROLLER_WIDTH, CONTROLLER_HEIGHT);
    
    // ラベル
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,CONTROLLER_WIDTH,BUTTON_HEIGHT)];
    label.text = @"Sound";
    label.textColor = [UIColor greenColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:label];

    // UPボタン
    upButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    upButton.frame = CGRectMake(10, 45, BUTTON_WIDTH, BUTTON_HEIGHT);
    [upButton setTitle:@"Up" forState:UIControlStateNormal];
    [upButton addTarget:self
                 action:@selector(upButtonTouched:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upButton];
    

    // DOWNボタン
    downButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    downButton.frame = CGRectMake(10,100, BUTTON_WIDTH, BUTTON_HEIGHT);
    [downButton setTitle:@"Down" forState:UIControlStateNormal];
    [downButton addTarget:self
                   action:@selector(downButtonTouched:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downButton];
}

- (void)upButtonTouched:(UIButton*)sender
{
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    if (musicPlayer.volume < 1.0f){
        musicPlayer.volume += A_VOLUME;
        AudioServicesPlaySystemSound(SOUND_ID_FOR_VOLUME);
    }
    else {
        AudioServicesPlaySystemSound(SOUND_ID_FOR_LIMIT);
    }
}


- (void)downButtonTouched:(UIButton*)sender
{
    MPMusicPlayerController* musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    if (musicPlayer.volume > 0.0f){
        musicPlayer.volume -= A_VOLUME;
        AudioServicesPlaySystemSound(SOUND_ID_FOR_VOLUME);
    }
    else {
        AudioServicesPlaySystemSound(SOUND_ID_FOR_LIMIT);
    }

}

@end
