//
//  CDResultViewController.m
//  Demo
//
//  Created by Nadiia Dovbysh on 1/29/16.
//  Copyright © 2016 Сloudipsp. All rights reserved.
//

#import "CDResultViewController.h"

@interface CDResultViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation CDResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textLabel.text = self.result;
}

@end
