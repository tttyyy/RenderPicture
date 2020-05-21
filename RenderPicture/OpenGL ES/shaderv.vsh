attribute vec4 position;
attribute vec2 textCoordinate;
varying lowp vec2 varytextCoord;

void main(){
    varytextCoord = textCoordinate;//vec2(textCoordinate.x,1.0-textCoordinate.y);
    gl_Position = position;
}
