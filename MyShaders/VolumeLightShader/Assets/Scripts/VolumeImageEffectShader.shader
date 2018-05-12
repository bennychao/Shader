Shader "Hidden/VolumeImageEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FrontMainTex ("Front Texture", 2D) = "white" {}
		_BackMainTex ("Back Texture", 2D) = "white" {}

		_FogColor("Fog Color", Color) =  (1,1,1,1)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;
			half4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.uv2 = v.uv;
				//for common texture
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv.y = 1-o.uv.y;
				#endif

				return o;
			}



			sampler2D _FrontMainTex;
			sampler2D _BackMainTex;
			fixed4 _FogColor;

			float _VolumeFactor;	//volume camera's far plane

			sampler2D_float _CameraDepthTexture;

			half4 _CameraDepthTexture_ST;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv2);
				fixed4 colback = tex2D(_BackMainTex, i.uv);
				fixed4 colfront = tex2D(_FrontMainTex, i.uv);


				float depthback = colback.r * _VolumeFactor;
				float depthfront = colfront.r * _VolumeFactor;



				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				d = LinearEyeDepth(d); //real world distance
				//d = Linear01Depth(d); //map to 0~1
				if (d < depthfront){
					return col;
				}
				// just invert the colors
				//col = 1 - col;

				depthback = min(d, depthback);

				fixed a =  ( (depthback - depthfront) / _VolumeFactor * 3).r;

				return fixed4(lerp(col.rgb, _FogColor.rgb, a), 1);
			}
			ENDCG
		}
	}
}
