//
//  FirstViewController.m
//  iMocs
//
//  Created by akh on 2018-10-24.
//  Copyright © 2018 akh. All rights reserved.
//

#import "FirstViewController.h"
@import Mapbox;

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet MGLMapView *mapView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.mapView.logoView.hidden = YES;
}


@end
