attribute vec3 position;
attribute vec3 normal;
attribute vec3 color;
attribute vec3 texture;
//ONLY FOR INSTANCED JELLYFISH attribute vec3 offset;

uniform mat4 uWorld;
uniform mat4 uWorldViewProj;
uniform mat4 uWorldInvTranspose;
uniform vec3 uLightPos;
uniform float uLightRadius;
uniform vec4 uLightCol;
uniform vec4 uAmbientCol;
uniform vec4 uFresnelCol;
uniform float uFresnelPower;
uniform float uCurrentTime;

varying vec2 vTextureCoord;
varying vec4 vWorld;
varying vec3 vDiffuse;
varying vec3 vAmbient;
varying vec3 vFresnel;

//varying vec3 vColor;
  
void main(void)
{ 
/*    
    vColor = normalize(normal);
    gl_Position = vec4(position, 1.0);
*/

    //Vertex Animation
    float speed = uCurrentTime / 15.0;
    float localoffset = smoothstep(0.0, 1.0, max(0.0, -position.y-0.8) / 10.0);
    vec3 pos = position + //ONLY FOR INSTANCED JELLYFISH offset +
        color / 12.0 *
        sin(speed * 15.0 + position.y / 2.0) * (1.0 - localoffset);
    pos = pos + color / 8.0 *
        sin(speed * 30.0 + position.y / 0.5) * (1.0 - localoffset);
    vec4 pos4 = vec4(pos, 1.0);
    gl_Position = uWorldViewProj * pos4; 

    vWorld = uWorld * pos4;
    vec3 vVertexNormal = normalize((uWorldInvTranspose * vec4(normal, 1.0)).xyz);

    //diffuse
    vec3 lightDir = normalize(uLightPos - vWorld.xyz);
    float diffuseProduct = max(dot(normalize(vVertexNormal.xyz), lightDir), 0.0);
    float lightFalloff = pow(max(1.0-(distance(uLightPos, vWorld.xyz)/uLightRadius), 0.0),2.0);
    vDiffuse = uLightCol.rgb * vec3(diffuseProduct * lightFalloff * uLightCol.a);

    //ambient (top)
    vAmbient = uAmbientCol.rgb * vec3(uAmbientCol.a) * vVertexNormal.y;

    //fresnel
    vec4 worldPos = uWorld * pos4;
    vec3 vWorldEyeVec = normalize(worldPos.xyz/worldPos.w); 
    float fresnelProduct = pow(1.0 - max(abs(dot(vVertexNormal, -vWorldEyeVec)), 0.0), uFresnelPower);
    vFresnel = uFresnelCol.rgb * vec3(uFresnelCol.a * fresnelProduct);

    // texcoord
    vTextureCoord = texture.xy;



}