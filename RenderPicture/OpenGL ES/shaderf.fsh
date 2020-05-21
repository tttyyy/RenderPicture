precision lowp float;
varying lowp vec2 varytextCoord;
uniform sampler2D colorMap;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main(){
    vec4 tmp = texture2D(colorMap,varytextCoord);
    float luminance = dot(tmp.rgb, W);
    gl_FragColor = vec4(vec3(luminance), 1.0);
}

//varying lowp vec2 varytextCoord;
//uniform sampler2D colorMap;
//
//void main()
//{
//    lowp vec4 temp = texture2D(colorMap, varytextCoord);
//    // gl_FragColor = texture2D(colorMap, varyTextCoord);
//    gl_FragColor = temp;
//
//}
