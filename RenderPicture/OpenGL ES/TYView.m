//
//  TYView.m
//  RenderPicture
//
//  Created by tangyj on 2020/3/18.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import "TYView.h"
@import OpenGLES;


@interface TYView()

@property(nonatomic,strong)CAEAGLLayer *myEagLayer;

@property(nonatomic,strong)EAGLContext *myContext;

@property(nonatomic,assign)GLuint myColorRenderBuffer;

@property(nonatomic,assign)GLuint myColorFrameBuffer;

@property(nonatomic,assign)GLuint myPrograme;


@end

@implementation TYView

-(void)layoutSubviews
{
    [self setupLayer];
    
    [self setupContext];
    
    [self deleteRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    
    [self setupFrameBuffer];
    
    [self renderLayer];
}

-(void)renderLayer
{
    glClearColor(0.3f, 0.45f, 0.5f, 1.0f);
    //清除屏幕
    glClear(GL_COLOR_BUFFER_BIT);
    
    //设置视口
    GLuint scale = [UIScreen mainScreen].scale;
    glViewport(CGRectGetMinX(self.frame)*scale, CGRectGetMinY(self.frame)*scale, CGRectGetMaxX(self.frame)*scale, CGRectGetMaxY(self.frame)*scale);
    //
    
    NSString *vshflie = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fshflie = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    self.myPrograme = [self loadShaders:vshflie Withfrag:fshflie];
    
    glLinkProgram(self.myPrograme);
    GLint linkStatus;
    
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.myPrograme, sizeof(message), 0, message);
        NSLog(@"%s",message);
        return;
    }
    
    NSLog(@"program link success!");
    
    glUseProgram(self.myPrograme);
    
    
    // 顶点数据
    GLfloat attrArr[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    
    GLuint arrBuffer;
    
    glGenBuffers(1, &arrBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, arrBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    
    // 将顶点数据 纹理数据 传入。
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL);
    
    
    GLuint texture = glGetAttribLocation(self.myPrograme, "textCoordinate");
    
    glEnableVertexAttribArray(texture);
    
    glVertexAttribPointer(texture, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 3);
    
    
    //    // 初始化好 GL_TEXTURE0 -》
    [self setupTexture:@"zhou.jpg"];
    
    glUniform1i(glGetUniformLocation(self.myPrograme, "colorMap"), 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

//从图片中加载纹理
- (GLuint)setupTexture:(NSString *)fileName {
    
    
    CGImageRef imageref = [UIImage imageNamed:fileName].CGImage;
    
    size_t width = CGImageGetWidth(imageref);
    size_t height = CGImageGetHeight(imageref);
    
    GLubyte *spritedata = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef context = CGBitmapContextCreate(spritedata, width, height, 8, width*4,CGImageGetColorSpace(imageref), kCGImageAlphaPremultipliedLast);
    
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, rect, imageref);
    
    
    //    glBindTexture(GL_TEXTURE_2D, 0);
    
//    glActiveTexture(GL_TEXTURE0);
//    GL_TEXTURE texture;
//    glGenTextures(1, <#GLuint *textures#>)
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spritedata);
    //        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spritedata);
    
    
    free(spritedata);
    CGContextRelease(context);
    
    return 0;
}

-(void)setupFrameBuffer
{
    GLuint frameBuffer;
    
    glGenFramebuffers(1, &frameBuffer);
    
    self.myColorFrameBuffer = frameBuffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

-(void)setupRenderBuffer
{
    GLuint renderBuffer;
    
    glGenRenderbuffers(1, &renderBuffer);
    
    self.myColorRenderBuffer = renderBuffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    
    //将可绘制对象drawable object's  CAEAGLLayer的存储绑定到OpenGL ES renderBuffer对象
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

-(void)deleteRenderAndFrameBuffer
{
    if (self.myColorFrameBuffer) {
        glDeleteBuffers(1, &_myColorFrameBuffer);
        self.myColorFrameBuffer = 0;
    }
    if (self.myColorRenderBuffer) {
        glDeleteBuffers(1, &_myColorRenderBuffer);
        self.myColorRenderBuffer = 0;
    }
}


-(void)setupContext
{
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!self.myContext) {
        return;
    }
    
    [EAGLContext setCurrentContext:self.myContext];
    
}

-(void)setupLayer
{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    
    //    _myEagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false),kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false,kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
    
    
}

+(Class)layerClass
{
    return [CAEAGLLayer class];
}


#pragma mark --shader
-(GLuint)loadShaders:(NSString *)vert Withfrag:(NSString *)frag
{
    
    GLuint vshader,fshader;
    
    GLuint program = glCreateProgram();
    
    
    [self compileShader:&vshader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fshader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    
    glDeleteShader(vshader);
    glDeleteShader(fshader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = [content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
}



@end
