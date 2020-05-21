//
//  MetalViewController.m
//  RenderPicture
//
//  Created by tangyj on 2020/3/17.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import "MetalViewController.h"
#import "TYRender.h"

@import MetalKit;

@interface MetalViewController ()
{
    MTKView *_view;
    TYRender *_renderer;
}
@end

@implementation MetalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _view = (MTKView *)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    
    if (!_view.device) {
        NSLog(@"metal create device faild");
        return;
    }
    
    _renderer = [[TYRender alloc] initWithMetalKitView:_view];
    
    _view.delegate = _renderer;

    if (!_renderer) {
        NSLog(@"render Create failed");
        return;
    }
    
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    
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
