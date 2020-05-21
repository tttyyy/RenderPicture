//
//  OpenGLViewController.m
//  RenderPicture
//
//  Created by tangyj on 2020/3/18.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import "OpenGLViewController.h"
#import "TYView.h"

@interface OpenGLViewController ()

@property (nonatomic,strong) TYView *tyview;
@end

@implementation OpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tyview = (TYView *)self.view;
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
