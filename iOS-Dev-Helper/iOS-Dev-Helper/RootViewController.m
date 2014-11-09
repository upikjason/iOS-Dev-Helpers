//
//  RootViewController.m
//
//  Created by luongnguyen on 10/30/14.
//  Copyright (c) 2014 upikjason. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

#pragma mark INIT
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    pdfView.frame = self.view.bounds;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"RoR" ofType:@"pdf"];
//    pdfView.highlightKeyword = @"Node";
    [pdfView loadPDFURL:[NSURL fileURLWithPath:path]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark MAIN
@end
