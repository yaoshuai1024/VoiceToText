//
//  ViewController.m
//  语音识别-将声音转换为文字显示
//
//  Created by yaoshuai on 2016/11/15.
//  Copyright © 2016年 yss. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

/**
 录的音频文件保存的路径
 */
@property(nonatomic,copy) NSString *savedFilepath;

/**
 /rɪ'kɔ:rdə(r)/ 录音机
 */
@property(nonatomic,strong) AVAudioRecorder *recorder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *
     typedef NS_ENUM(NSInteger, SFSpeechRecognizerAuthorizationStatus) {
     SFSpeechRecognizerAuthorizationStatusNotDetermined, 未决定，用户没有选择是否给予授权
     SFSpeechRecognizerAuthorizationStatusDenied,        拒绝，用户不让应用有语音识别的权限
     SFSpeechRecognizerAuthorizationStatusRestricted,    受限制，手机给熊孩子了，不能让他随便玩，设置-应用-设备允许访问
     SFSpeechRecognizerAuthorizationStatusAuthorized,    同意授权
     };
     */
    
    // 请求语音识别授权，需要先设置Info.plist文件
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"语音识别授权成功");
                break;
            default:
                break;
        }
    }];
    
    // 语音识别必须使用真机，真机进行录音操作最好设置音频会话类型，不设置有时行有时不行
    // 常用的类型
    // AVAudioSessionCategoryPlayback：应用可以播放音效
    // AVAudioSessionCategoryRecord：应用可以进行录音
    // AVAudioSessionCategoryPlayAndRecord：应用即可播放音频，也可录音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
}

#pragma mark - 开始录音
- (IBAction)startRecord:(id)sender {
    // 录音之前，也要先授权，需要先设置Info.plist文件
    [self.recorder record];
}

#pragma mark - 结束录音
- (IBAction)stopRecord:(id)sender {
    [self.recorder stop];
}

#pragma mark - 语音识别
- (IBAction)recognizerAction:(id)sender {
    // 创建语音识别器，并设置音频的语种
    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    
    // 创建识别请求，注意，这里要用SFSpeechRecognitionRequest的子类SFSpeechURLRecognitionRequest
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:[NSURL fileURLWithPath:self.savedFilepath]];
    
    // 只返回最终结果(不返回片段，说明识别完了)，与86行“if(result.final)”二选一即可
    request.shouldReportPartialResults = NO;
    
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if(result.final){ // 是否完整了识别完了，再展示，还是识别着展示着(文字会一节一节的出来)，与83行“request.shouldReportPartialResults = NO;”二选一即可
            // 识别出来的内容是一个数组，有可能说话带方言或不清楚，所以会识别出多个
            // 这里选择最佳识别内容，进行展示
            self.contentLabel.text = result.bestTranscription.formattedString;
        }
    }];
}

#pragma mark - 属性懒加载
- (AVAudioRecorder *)recorder{
    if(_recorder == nil){
        self.savedFilepath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"yayaya.wav"];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.savedFilepath] settings:@{} error:nil];
    }
    return _recorder;
}

@end
