//
//  TYRender.h
//  RenderPicture
//
//  Created by tangyj on 2020/3/17.
//  Copyright © 2020 tangyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface TYRender : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
