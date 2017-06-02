//this is a shader that makes object appear gradually with a transparent map
Shader "LS/GraduallyAppear" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_SecondTex("Second Tex", 2D) = "black"{}
		_Color("SecondColor", Color) = (1, 1, 1, 1)
		_BumpMap ("Normal Map", 2D) = "bump" {}

		_Begin("begin", float) = 0
		_End("end", float) = 1
		_Limit("LimitOfGradual", Range(0, 1)) = 0
		_Range("GradualRange", float) = 1
		_GDTex("GradualTexr", 2D) = "black"{}
	}
	SubShader {
		Tags{"Queue"="Transparent" "IgnoreProjector"="alphaue" "RenderType"="alphaansparent"}
		Pass{
			ZWrite On
			ColorMask 0
		}
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			sampler2D _SecondTex;
			float4 _SecondTex_ST;
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;

			float _Begin;
			float _End;
			fixed _Limit;
			float _Range;
			sampler2D _GDTex;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 vertex : TEXCOORD3;
				float2 se_uv : TEXCOORD4;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.vertex = v.vertex;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.se_uv.xy = v.texcoord.xy * _SecondTex_ST.xy + _SecondTex_ST.zw;
				
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed mixed = tex2D(_SecondTex, i.se_uv).r;
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * (1 - mixed) + mixed * _Color.rgb;
				fixed alpha = 1;

				float gd = (_End - _Begin) * _Limit + _Begin;
				if(i.vertex.y > gd + _Range){
					alpha = 0;
				}
				else if(i.vertex.y > gd){
					albedo = tex2D(_GDTex, i.uv).rgb;
					alpha = 1 - (i.vertex.y - gd) / _Range;
				}

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
			 	fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
			 	fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
			 	fixed3 specular = _LightColor0.rgb * max(0, dot(tangentNormal, halfDir));
				return fixed4(ambient + diffuse, alpha);
			}
			
			ENDCG
		}
	} 
	FallBack "alphaansparent/VertexLit"
}
