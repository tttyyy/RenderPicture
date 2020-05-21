//
//  TYShaderTypes.h
//  RenderPicture
//
//  Created by tangyj on 2020/3/17.
//  Copyright © 2020 tangyj. All rights reserved.
//

#ifndef TYShaderTypes_h
#define TYShaderTypes_h

#include <simd/simd.h>

typedef enum TYVertexInputIndex{
    TYVertexInputIndexVertices = 0,
    TYVertexInputIndexViewportSize = 1,
} TYVertexInputIndex;

typedef enum TYTextureIndex{
    TYTextureIndexBaseColor = 0
}TYTextureIndex;


typedef struct{
    vector_float2 position;
    vector_float2 textureCoodinate;
} TYVertex;

#endif /* TYShaderTypes_h */
