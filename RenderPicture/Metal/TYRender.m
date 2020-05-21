//
//  TYRender.m
//  RenderPicture
//
//  Created by tangyj on 2020/3/17.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import "TYRender.h"

#import "TYShaderTypes.h"


@implementation TYRender
{
    id<MTLDevice> _device;
    
    id<MTLRenderPipelineState> _pipelineState;
    
    id<MTLCommandQueue> _commandQueue;
    
    id<MTLTexture> _texture;
    
    id<MTLBuffer> _vertices;
    
    NSInteger _numVertices;
    
    vector_uint2 _viewportsize;
    
    MTKView *tyMTKView;
}


- (instancetype)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if (self) {
        _device = mtkView.device;
        
        tyMTKView = mtkView;
        
        [self setupVertex];
        
        [self setupPipeline];
        
        [self setupTextureJpeg];
        
    }
    return self;
}

- (void)setupVertex{
    static const TYVertex quadVertices[] = {
        { {  1.0,  -1.0 },  { 1.f, 0.f } },
        { { -1.0,  -1.0 },  { 0.f, 0.f } },
        { { -1.0,   1.0 },  { 0.f, 1.f } },
        
        { {  1.0,  -1.0 },  { 1.f, 0.f } },
        { { -1.0,   1.0 },  { 0.f, 1.f } },
        { {  1.0,   1.0 },  { 1.f, 1.f } },
    };
    
    _vertices = [_device newBufferWithBytes:quadVertices length:sizeof(quadVertices) options:MTLResourceStorageModeShared];
    
    _numVertices = sizeof(quadVertices)/sizeof(tyMTKView);
}


- (void)setupPipeline{
    id<MTLLibrary> defaulLiabray = [_device newDefaultLibrary];
    
    id<MTLFunction> vertexFunc = [defaulLiabray newFunctionWithName:@"vertexShader"];
    
    id<MTLFunction> fragmentFunc = [defaulLiabray newFunctionWithName:@"fragmentShader"];

    MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    descriptor.vertexFunction = vertexFunc;
    descriptor.fragmentFunction = fragmentFunc;
    descriptor.colorAttachments[0].pixelFormat = tyMTKView.colorPixelFormat;
    
    NSError *error = nil;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    
    if (!_pipelineState) {
        NSLog(@"%@",error);
    }
    
    _commandQueue = [_device newCommandQueue];
    
}

- (void)setupTextureJpeg{
    UIImage *image = [UIImage imageNamed:@"zhou.jpg"];
    
    MTLTextureDescriptor *textureDesc = [[MTLTextureDescriptor alloc] init];
    textureDesc.pixelFormat = MTLPixelFormatRGBA8Unorm;
    textureDesc.width = image.size.width;
    textureDesc.height = image.size.height;
    
    _texture = [_device newTextureWithDescriptor:textureDesc];
    
    
    Byte *imagebyte = [self loadImage:image];
    
    _viewportsize.x = image.size.width;
    _viewportsize.y = image.size.height;
    
    
    MTLRegion region = {{0,0,0},{_viewportsize.x, _viewportsize.y, 1}};

    if (imagebyte) {
        [_texture replaceRegion:region mipmapLevel:0 withBytes:imagebyte bytesPerRow:4*image.size.width];
        
        free(imagebyte);
        imagebyte = NULL;
    }
}

//从UIImage 中读取Byte 数据返回
- (Byte *)loadImage:(UIImage *)image {
    CGImageRef spriteImage = image.CGImage;
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    Byte * spriteData = (Byte *) calloc(width * height * 4, sizeof(Byte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    CGContextRelease(spriteContext);
    
    return spriteData;
}


- (void)drawInMTKView:(nonnull MTKView *)view {
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    commandBuffer.label = @"cb";
    
    MTLRenderPassDescriptor *rendPassDesc = view.currentRenderPassDescriptor;
    
    rendPassDesc.colorAttachments[0].clearColor = (MTLClearColor){1.0,1.0,1.0,1.0};
    
    if (rendPassDesc != nil) {
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:rendPassDesc];
        
        [renderEncoder setViewport:(MTLViewport){view.center.x , view.center.y , tyMTKView.bounds.size.width, tyMTKView.bounds.size.height , -1, 1}];
        
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        [renderEncoder setVertexBuffer:_vertices offset:0 atIndex:TYVertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportsize length:sizeof(_viewportsize) atIndex:TYVertexInputIndexViewportSize];
        
        [renderEncoder setFragmentTexture:_texture atIndex:TYTextureIndexBaseColor];
        
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable: view.currentDrawable];
    }
    
    [commandBuffer commit];
    
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
//    _viewportsize.x = size.width;
//    _viewportsize.y = size.height;
}

@end
