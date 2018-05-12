Shader "Unlit/DepthDebuger"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			sampler2D_float _CameraDepthTexture;

			half4 _CameraDepthTexture_ST;
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				d = Linear01Depth(d); //map to 0~1
				//d = LinearEyeDepth(d);
				return fixed4(d, 0, 0, 1);
			}
			ENDCG
		}

			Pass
			{
				Tags{ "LightMode" = "ShadowCaster" }

						CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_shadowcaster
		#include "UnityCG.cginc"

					struct v2f {
						V2F_SHADOW_CASTER;
					};

					v2f vert(appdata_base v)
					{
						v2f o;
						TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
							return o;
					}

					float4 frag(v2f i) : SV_Target
					{
						SHADOW_CASTER_FRAGMENT(i)
					}
				ENDCG
			}

	}
}
