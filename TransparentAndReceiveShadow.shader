//this will make a plane transparent or colorful and if the plane can receive others' shadow
Shader "LS/TransparentAndReceiveShadow" {
Properties
{
    _ShadowColor("ColorOfShadow", Color) = (0, 0, 0, 1)
    _PlaneColor("ColorOfPlane", Color) = (1, 1, 1, 1)
    //_IfColor("<1:transparent plane \n >=1:color plane", float) = 0
    //[ToggleOff] _IfColor("PlaneTransparent", Float) = 0.0
		[Enum(Transparent,0,Color,1)] _IfColor ("choose the plane", int) = 0
}
 
CGINCLUDE
 
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
 
uniform sampler2D _MainTex;
 
ENDCG
 
SubShader
{
    Tags { "RenderType"="Opaque" }
    LOD 200
 
    Pass
    {
       Lighting On
 
       Tags {"LightMode" = "ForwardBase"}
       CGPROGRAM
 
       #pragma vertex vert
       #pragma fragment frag
       #pragma multi_compile_fwdbase
 
       fixed4 _PlaneColor;
       fixed4 _ShadowColor;
       int _IfColor;
       struct v2f
       {
         float4 pos     : SV_POSITION;
         LIGHTING_COORDS(3,4)
       };
 
       v2f vert(appdata_tan v)
       {
         v2f o;
         o.pos = UnityObjectToClipPos(v.vertex);
         TRANSFER_VERTEX_TO_FRAGMENT(o);
         return o;
       }

       float4 frag(v2f i) : COLOR
       {
         //float3 lightColor = _LightColor0.rgb;
         //float3 lightDir = _WorldSpaceLightPos0;
         //float4 colorTex = (1, 1, 1, 1);
         float  atten = LIGHT_ATTENUATION(i);
        //  float3 N = float3(0.0f, 1.0f, 0.0f);
        //  float  NL = saturate(dot(N, lightDir));
        if(atten){
          if(_IfColor == 1){
            return _PlaneColor;
          }
          discard;
        }
        //  float3 color = colorTex.rgb * lightColor * NL * atten;
         return _ShadowColor;
       }
 
       ENDCG
    }
} 
FallBack "Diffuse"
}