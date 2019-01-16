//
//  MJPEGViewController.m
//  iMocs
//
//  Created by akh on 2018-10-29.
//  Copyright © 2018 akh. All rights reserved.
//

#import "MJPEGViewController.h"

@interface MJPEGViewController ()
- (IBAction)reloadTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *connectedView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) dispatch_source_t timerSource;
@property (nonatomic, strong) NSURLSession *session;
@property BOOL playing;
@end

@implementation MJPEGViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  config.timeoutIntervalForRequest = 0.4;
  config.HTTPMaximumConnectionsPerHost = 1;
  config.HTTPShouldUsePipelining = YES;
  self.session = [NSURLSession sessionWithConfiguration:config];
}

- (void) fetchOne {
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.12.1:8080/?action=snapshot"]];
  request.networkServiceType = NSURLNetworkServiceTypeResponsiveData;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"error dl image %@", [error localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
          self.connectedView.backgroundColor = [UIColor redColor];
        });
      }
      
      UIImage *downloadedImage = [UIImage imageWithData:data];
      if (downloadedImage != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.imageView.image = downloadedImage;
          self.connectedView.backgroundColor = [UIColor greenColor];
        });
      }
      dispatch_semaphore_signal(sem);
    }];
    
    [dataTask resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    if (self.playing) {
      [self fetchOne];
    }
  });
}

- (void) play {
  self.playing = YES;
  [self fetchOne];
}

- (void) stop {
  self.playing = NO;
  self.connectedView.backgroundColor = [UIColor redColor];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self play];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self stop];
}

- (IBAction)reloadTouched:(id)sender {
  [self stop];
  [self play];
}

@end
