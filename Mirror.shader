//this is a shader that can make a plane a mirror(need a Render Texture and a camera to capture the mirror view, and you had better use a script to control the mirror camera)
Shader "LS/Mirror" {
	Properties {
		_MainTex("MainTex", 2D) = "white"{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass{
			LOD 200
			
			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;

			struct a2v{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				fixed4 uv : TEXCOORD0;
			};
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				o.uv.y = 1 - o.uv.y;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
