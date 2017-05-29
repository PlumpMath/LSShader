//Show the same color within a certain height range and there is a line between two range
//2017_5_4 去掉了面板上的无关参数 同时dep判断什么的改用float 防止设置小数时出错
Shader "LS/ContourLine" {
  Properties {
    _begin("the coordinate of begin", float) = 0
        // _ColorBe("开始颜色", Color) = (1, 0, 0)
        // _ColorEN("结束颜色", Color) = (1, 1, 1)
    _Color1th("first range color", Color) = (1, 0, 0)
    _Color2th("first range color", Color) = (1, 0, 0)
    _Color3th("first range color", Color) = (1, 0, 0)
    _Color4th("first range color", Color) = (1, 0, 0)
    _Color5th("first range color", Color) = (1, 0, 0)
    _Color6th("first range color", Color) = (1, 0, 0)
    _Color7th("first range color", Color) = (1, 0, 0)
    _Width("width of one range", float) = 0.5
    _Range("wide of line", float) = 0.1
    _ColorLine("color of line", Color) = (0, 0, 0)
		//_MainTex("Base (RGB)", 2D) = "white" {}
		//_Number("display name", Range(0, 1)) = 0 //滑动条调节
    // _MainTex ("Base (RGB)", 2D) = "white" {}
    // _Color1 ("Color 1", Color) = (1, 1, 1, 1)
    // _Color2 ("Color 2", Color) = (1, 1, 1, 1)
    // _BorderColor ("边界颜色", Color) = (1, 1, 1, 1)
    // _BorderThick ("边界厚度", Range(0.01, 3)) = 0.1
    // _Bulge ("边界凸出程度", Range(0.01, 0.3)) = 0.08
    // _CullPos ("裁剪球位置", Range(0, 3)) = 3
    // _CullRadius ("裁剪球半径", Range(0.1, 5)) = 1
  }
  SubShader {
    Tags { "RenderType" = "Opaque" }
    LOD 200

        CGPROGRAM
#pragma surface surf Lambert vertex:Myvert fragment:frag
        float _begin;
    float _Width;
    float _Range;
    float4 _ColorLine;
    float4 _Color1th;
    float4 _Color2th;
    float4 _Color3th;
    float4 _Color4th;
    float4 _Color5th;
    float4 _Color6th;
    float4 _Color7th;

    fixed4 _Color1;
    fixed4 _Color2;
    fixed4 _BorderColor;
    float _BorderThick;
    float _Bulge;
    float _CullPos;
    float _CullRadius;

    struct Input {
      float2 uv_MainTex;
      float3 worldSpacePos;
    };

    inline float GetDis(float3 pos) {
      return distance(pos, float3(_CullPos, _CullPos, _CullPos));
    }
    void Myvert(inout appdata_full v, out Input IN) {
      UNITY_INITIALIZE_OUTPUT(Input, IN);
      IN.worldSpacePos = mul(unity_ObjectToWorld, v.vertex);
      if (abs(GetDis(IN.worldSpacePos.xyz) - _CullRadius) <= _BorderThick / 2) {
        v.vertex.xyz += v.normal * _Bulge;
      }
    }

    void surf(Input IN, inout SurfaceOutput o) {
      float4 col;
      float dep = IN.worldSpacePos.x - _begin;
      int now = (int)(dep / _Width);
      // now = 1;
      if (dep > 0) {
        dep -= _Width * now;
        if (dep < _Range) {
          col = _ColorLine;
        } else {
          // int now = (int)((IN.worldSpacePos.x - _begin) / _Width);
          float t =dep / _Width;
          switch (now) {
          case 0:
            col = _Color1th;
            break; 
          case 1:
            col = _Color2th;
            break; 
          case 2:
            col = _Color3th;
            break; 
          case 3:
            col = _Color4th;
            break; 
          case 4:
            col = _Color5th;
            break; 
          case 5:
            col = _Color6th;
            break; 
          case 6:
            col = _Color7th;
            break;
          default:
            col = _ColorLine;
            break;
          }
          // col = _Color1th;// allCol[0];
        }
      }
      else{
        col = _ColorLine;
      }

      // fixed4 tint;
      // tint = IN.
      // if(abs(GetDis(IN.worldSpacePos.xyz) - _CullRadius) <= _BorderThick / 2)
      // {
      //     tint = _BorderColor;
      // }
      // else if(GetDis(IN.worldSpacePos.xyz) > _CullRadius)
      // {
      //     tint = _Color1;
      // }
      // else
      // {
      //     tint = _Color2;
      // }
      // half4 c = tex2D (_MainTex, IN.uv_MainTex);
      o.Albedo = col.rgb; // tint.rgb * c.rgb;
      o.Alpha = 0;
    }

#include "UnityCG.cginc"
    sampler2D _MainTex;
		float4 _MainTex_ST;
		float uvOffsetx;
		float uvOffsety;
		float _Number;
		uniform float width;
		uniform float height;
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

    		float4 frag(v2f i) : COLOR
		{
			uvOffsetx = i.uv.x / width;
		uvOffsety = i.uv.y / height;
		float4 s1 = tex2D(_MainTex,i.uv + float2(uvOffsetx,0.00));//右
		float4 s2 = tex2D(_MainTex,i.uv + float2(-uvOffsetx,0.00));//左
		float4 s3 = tex2D(_MainTex,i.uv + float2(0.00,uvOffsety));//上
		float4 s4 = tex2D(_MainTex,i.uv + float2(0.00,-uvOffsety));//下
		float4 s5 = tex2D(_MainTex,i.uv + float2(uvOffsetx,uvOffsety));//右上
		float4 s6 = tex2D(_MainTex,i.uv + float2(-uvOffsetx,uvOffsety));//左上
		float4 s7 = tex2D(_MainTex,i.uv + float2(uvOffsetx,-uvOffsety));//右下
		float4 s8 = tex2D(_MainTex,i.uv + float2(-uvOffsetx,-uvOffsety));//左下

		float4 texCol = tex2D(_MainTex,i.uv);
		float4 outp;

		//float pct1 = 0.007164f;//pct：权
		//float pct2 = 0.033120f;
		float pct1 = 0.007f;//pct：权
		float pct2 = 0.02f;
		outp = (s5 + s6 + s7 + s8)*pct1 + (s1 + s2 + s3 + s4)*pct2 + texCol*_Number;
		//outp = pct1*(s1+s2+s3+s4+s5+s6+s7+s8+texCol)/9.0f;//中值滤波
		return outp;
		}
    ENDCG
  }
  FallBack "Diffuse"
}