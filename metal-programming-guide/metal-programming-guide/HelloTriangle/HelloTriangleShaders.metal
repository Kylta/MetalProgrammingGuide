//
//  HelloTriangleShaders.metal
//  metal-programming-guide
//
//  Created by Christophe Bugnon on 5/8/20.
//  Copyright © 2020 Christophe Bugnon. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(const device packed_float3* vertex_array [[buffer(0)]],
                           unsigned int vid [[vertex_id]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment() {
    return half4(1.0);
}
