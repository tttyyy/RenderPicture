//
//  TYShaders.metal
//  RenderPicture
//
//  Created by tangyj on 2020/3/17.
//  Copyright © 2020 tangyj. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "TYShaderTypes.h"

typedef struct
{
    float4 clipSpacePosition [[position]];
    float2 textureCoodinate;
} RasterizerData;


vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant TYVertex *vertexArray [[buffer(TYVertexInputIndexVertices)]],
             constant vector_uint2 *viewPortPointer [[buffer(TYVertexInputIndexViewportSize)]])
{
    RasterizerData out;
    
    out.clipSpacePosition = float4(vertexArray[vertexID].position.x,vertexArray[vertexID].position.y, 0 , 1.0);
    
    out.textureCoodinate = vertexArray[vertexID].textureCoodinate;
    
    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]],
               texture2d<half> colorTexture [[texture(TYTextureIndexBaseColor)]])
{
    constexpr sampler textureSampler(mag_filter:: linear,
                                     min_filter:: linear);
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoodinate);
    
    return float4(colorSample);
}
