//
//  ViewController.m
//  test59
//
//  Created by niexiaobo on 2018/5/8.
//  Copyright © 2018年 NXB. All rights reserved.
//

#import "ViewController.h"
#import "ZipArchive.h"//解压zip
#import "AFNetworking.h"//异步下载
#import "SVProgressHUD.h"//进度和提示框
@interface ViewController () <ARSCNViewDelegate>
//https://github.com/niexiaobo/ResponsiveWebsite/raw/master/art.scnassets.zip
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong)NSURL *documentsDirectoryURL;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //指定存储路径
    self.documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    //需要加载的文件路径(以官方做好的文件测试)
    self.documentsDirectoryURL = [self.documentsDirectoryURL URLByAppendingPathComponent:@"art.scnassets/ship.scn"];
    //判断文件是否已下载
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/art.scnassets/ship.scn"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentsDirectory]) {
        [self downloadZip];//不存在,下载
    } else {
        [self addsceneView];//如果存在,显示
    }
}

//开始下载
- (void)downloadZip {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //url链接:zip下载
    NSURL *URL = [NSURL URLWithString:@"https://github.com/niexiaobo/ResponsiveWebsite/raw/master/art.scnassets.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //显示下载进度
        [SVProgressHUD showProgress:downloadProgress.fractionCompleted];
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //对文件解压
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *inputPath = [documentsDirectory stringByAppendingPathComponent:@"/art.scnassets.zip"];
        
        NSError *zipError = nil;
        
        [SSZipArchive unzipFileAtPath:inputPath toDestination:documentsDirectory overwrite:YES password:nil error:&zipError];
        
        if( zipError ){
            [SVProgressHUD showErrorWithStatus:@"解压失败"];
        }else {
            [SVProgressHUD showSuccessWithStatus:@"解压成功"];
            //开始绘制
            [self addsceneView];
        }
    }];
    
    [downloadTask resume];
}

//开始绘制
- (void)addsceneView {
    self.sceneView.delegate = self;
    self.sceneView.showsStatistics = YES;
    SCNScene *scene1 = [SCNScene sceneWithURL:self.documentsDirectoryURL options:nil error:nil];
    self.sceneView.scene = scene1;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

/*
 // Override to create and configure nodes for anchors added to the view's session.
 - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
 SCNNode *node = [SCNNode new];
 
 // Add geometry to the node...
 
 return node;
 }
 */

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}


@end

