/*******************************************************************************

                    AVFoundation フレームワーク用のマクロ関数
               ※プロジェクトにAVFoundationをリンクする必要があります。

                                                              (c) 2013 tyabuta.
 *******************************************************************************/

#ifndef TYABUTA_IOS_AVFOUNDATION_H
#define TYABUTA_IOS_AVFOUNDATION_H

#import <AVFoundation/AVFoundation.h>
#import "macro.h"

/*
 * サンプルバッファを画像としてカメラロールに保存する。
 */
NS_INLINE UIImage*
CMSampleBufferWriteToSavedPhotosAlbum(CMSampleBufferRef imageDataSampleBuffer){
    // jpegデータを取り出し
    NSData* jpeg_data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    // UIImage作成
    UIImage* image = [UIImage imageWithData:jpeg_data];
    // カメラロールへ保存
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    return image;
}

/*
 * AVCaptureStillImageAsynchronously
 * キャプチャ画像のサンプルバッファを取得する。
 * handler: 取得時の処理用ブロック構文
 */
typedef void (^AVCaptureStillImageAsynchronouslyBlock)(CMSampleBufferRef, NSError*);
NS_INLINE void
AVCaptureStillImageAsynchronously(AVCaptureStillImageOutput* stillImageOutput,
                                  AVCaptureStillImageAsynchronouslyBlock handler)
{
    AVCaptureConnection* capConnect =
    [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:capConnect
                                                  completionHandler:handler];
}

/*
 * キャプチャから静止画を取得しカメラロールに保存する。
 */
NS_INLINE void AVCaptureStillImageWriteToSavedPhotosAlbum(AVCaptureStillImageOutput* stillImageOutput) {
    AVCaptureStillImageAsynchronously
    (stillImageOutput, ^(CMSampleBufferRef imageDataSampleBuffer, NSError* error)
     {
         if (error){
             dmsg(@"Take picture failed %@", error);
         }
         else {
             CMSampleBufferWriteToSavedPhotosAlbum(imageDataSampleBuffer);
         }
     });
}

/*
 * キャプチャセッションにビデオの入力デバイスを追加する。
 * 入力デバイスの追加に成功した場合、YESを返す。
 */
NS_INLINE BOOL
AVCaptureVideoInputAddToSession(AVCaptureSession* captureSession){
    // 入力デバイス作成
    AVCaptureDeviceInput*   deviceInput = nil;
    AVCaptureDevice*      captureDevice = nil;
    NSError*                      error = nil;
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    deviceInput   = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (nil != error){
        dmsg(@"入力デバイス作成失敗: %@", error);
        return NO;
    }

    // 入力でバイスをキャプチャセッションにセット
    if (NO == [captureSession canAddInput:deviceInput]){
        dmsg(@"入力デバイスをキャプチャセッションに追加できません。");
        return NO;
    }
    [captureSession addInput:deviceInput];
    return YES;
}

/*
 * 現在のキャプチャセッションに対応できるか吐き出す。
 * captureSessionには先に入力デバイスを追加しておく必要があります。
 * 入力デバイスがないと全てYESと出力されてしまいます。
 */
NS_INLINE void AVCaptureSessionPresetsCanUseDump(AVCaptureSession* captureSession){
    // 利用可能なプリセット
    NSArray* const AVCaptureSessionPresets =
    @[AVCaptureSessionPresetPhoto,
      AVCaptureSessionPresetHigh,
      AVCaptureSessionPresetMedium,
      AVCaptureSessionPresetLow,
      AVCaptureSessionPreset352x288,
      AVCaptureSessionPreset640x480,
      AVCaptureSessionPreset1280x720,
      AVCaptureSessionPreset1920x1080,
      AVCaptureSessionPresetiFrame960x540,
      AVCaptureSessionPresetiFrame1280x720];

    // 現在のキャプチャセッションに対応できるか吐き出す。
    NSLog(@"--- AVCaptureSessionPresets ---");
    for (NSString* preset in AVCaptureSessionPresets) {
        NSLog(@"%@: %@", preset, [captureSession canSetSessionPreset:preset]? @"YES":@"NO");
    }
}


/*
 * キャプチャセッションの画質設定をおこなう。
 * リスト順に設定可能なプリセットを設定します。
 *
 * presets: AVCaptureSessionPreset~を優先順で配列にして渡す。
 *   戻り値: 設定できたプリセットを返す、設定可能なプリセットがなければnilを返します。
 */
NS_INLINE NSString*
AVCaptureSessionSetPresets(AVCaptureSession* captureSession, NSArray* presets){
    // リスト順に可能なプリセットを設定する。
    for (NSString* preset in presets){
        if ([captureSession canSetSessionPreset:preset]){
            [captureSession setSessionPreset:preset];
            dmsg(@"%@", preset);
            return preset;
        }
    }
    return nil;
}


/*
 * AVCaptureVideoPreviewLayerを作成し、レイヤーへ追加する。
 */
NS_INLINE AVCaptureVideoPreviewLayer*
AVCaptureVideoPreviewLayerAddToLayer
(AVCaptureSession* captureSession, CALayer* layer, CGRect frame){

    AVCaptureVideoPreviewLayer* preview =
    [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame        = frame;

    [layer addSublayer:preview];
    return preview;
}



#endif // TYABUTA_IOS_AVFOUNDATION_H


