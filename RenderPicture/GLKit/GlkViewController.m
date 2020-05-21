//
//  GLKViewController.m
//  RenderPicture
//
//  Created by tangyj on 2020/3/18.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import "GlkViewController.h"
@interface GlkViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *cEffect;
}
@end

@implementation GlkViewController
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(200, 60, 100, 40)];
    [btn setTitle:@"back" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    //1.OpenGL ES 相关初始化
    [self setUpConfig];
    
    //2.加载顶点/纹理坐标数据
    [self setUpVertexData];
    
    //3.加载纹理数据(使用GLBaseEffect)
    [self setUpTexture];
}
-(void)setUpTexture
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"zhou" ofType:@"jpg"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    cEffect = [[GLKBaseEffect alloc]init];
    cEffect.texture2d0.enabled = GL_TRUE;
    cEffect.texture2d0.name = textureInfo.name;
}

-(void)setUpVertexData
{
    GLfloat vertexData[] = {
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    //顶点坐标数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    
    //纹理坐标数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}

-(void)setUpConfig
{
    context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    //判断context是否创建成功
    if (!context) {
        NSLog(@"Create ES context Failed");
    }
    //设置当前上下文
    [EAGLContext setCurrentContext:context];
    
    //2.获取GLKView & 设置context
    GLKView *view =(GLKView *) self.view;
    view.context = context;
    
    //3.配置视图创建的渲染缓存区.
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    //4.设置背景颜色
    glClearColor(1, 0, 0, 1.0);
}

#pragma mark -- GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //1.
    glClear(GL_COLOR_BUFFER_BIT);
    
    //2.准备绘制
    [cEffect prepareToDraw];
    
    //3.开始绘制
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
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
