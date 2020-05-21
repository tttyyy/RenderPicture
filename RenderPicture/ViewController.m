//
//  ViewController.m
//  RenderPicture
//
//  Created by tangyj on 2020/3/17.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import "ViewController.h"
#import "Metal/MetalViewController.h"
#import "OpenGL ES/OpenGLViewController.h"
#import "GlkViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [UIView new];
    
    self.dataArray = @[@"Metal",@"OpenGL ES",@"GLKit"].mutableCopy;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSLog(@"metal");
        MetalViewController *vc = [[MetalViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }else if (indexPath.row == 1)
    {
        OpenGLViewController *ovc = [[OpenGLViewController alloc] init];
        [self presentViewController:ovc animated:YES completion:nil];
    }else
    {
        GlkViewController *vc = [[GlkViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 44)];
    label.text = self.dataArray[indexPath.row];
    [cell.contentView addSubview:label];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


@end
