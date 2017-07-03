//
//  CDStartViewController.m
//  Cloudipsp
//
//  Created by Nadiia Dovbysh on 6/30/17.
//  Copyright © 2017 Nadiia. All rights reserved.
//

#import "CDStartViewController.h"
#import "CDCustomProgramViewController.h"

@interface CDStartViewController ()

@end

@implementation CDStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
    
- (IBAction)customProgrammaticallyClicked:(UIButton *)sender {
    
    CDCustomProgramViewController *vc = [[CDCustomProgramViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
