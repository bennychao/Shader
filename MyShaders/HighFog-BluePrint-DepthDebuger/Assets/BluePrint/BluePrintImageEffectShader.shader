Shader "Hidden/BluePrintImageEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			//set by the graphic.Blit
			sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;
			half4 _MainTex_ST;

			//set by the shader pipeline
			sampler2D _CameraDepthNormalsTexture;
			half4 _CameraDepthNormalsTexture_ST;

			sampler2D_float _CameraDepthTexture;
			half4 _CameraDepthTexture_ST;

			//set the script
			half _SampleDistance;
			half _Sensitivity;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


//			inline half CheckSame (half2 centerNormal, float centerDepth, half4 theSample)
//			{
//				// difference in normals
//				// do not bother decoding normals - there's no need here
//				half2 diff = abs(centerNormal - theSample.xy) * _Sensitivity.y;
//				int isSameNormal = (diff.x + diff.y) * _Sensitivity.y < 0.1;
//				// difference in depth
//				float sampleDepth = DecodeFloatRG (theSample.zw);
//				float zdiff = abs(centerDepth-sampleDepth);
//				// scale the required threshold by the distance
//				int isSameDepth = zdiff * _Sensitivity.x < 0.09 * centerDepth;
//			
//				// return:
//				// 1 - if normals and depth are similar enough
//				// 0 - otherwise
//				
//				return isSameNormal * isSameDepth ? 1.0 : 0.0;
//			}	

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv[0] = v.uv;

				float2 uv = v.uv.xy;

				//for common texture
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					uv.y = 1-uv.y;
				#endif


				o.uv[1] = UnityStereoScreenSpaceUVAdjust(uv + _MainTex_TexelSize.xy * half2(1,1) * _SampleDistance, _MainTex_ST);
				o.uv[2] = UnityStereoScreenSpaceUVAdjust(uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance, _MainTex_ST);
				o.uv[3] = UnityStereoScreenSpaceUVAdjust(uv + _MainTex_TexelSize.xy * half2(-1,1) * _SampleDistance, _MainTex_ST);
				o.uv[4] = UnityStereoScreenSpaceUVAdjust(uv + _MainTex_TexelSize.xy * half2(1,-1) * _SampleDistance, _MainTex_ST);

				return o;
			}
			
			inline float NormalDotDistance(float2 uv1, float2 uv2)	//, out float dotDistance
			{
				half4 sample1 = tex2D(_CameraDepthNormalsTexture, uv1);
				//then d is 0~1

				float d1 = 0; 
				float3 normalout1;
				DecodeDepthNormal(sample1, d1, normalout1);

				half4 sample2 = tex2D(_CameraDepthNormalsTexture, uv2);
				//then d is 0~1

				float d2 = 0; 
				float3 normalout2;
				DecodeDepthNormal(sample2, d2, normalout2);

				float zdiff = abs(d1-d2);
//				if (zdiff < 0.01)
//				{
//					return -1;
//				}

				return zdiff < 1 ? abs( dot(normalout2, normalout1)) : -1;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float col = tex2D(_CameraDepthNormalsTexture, i.uv[0]);

				float dotDistance = NormalDotDistance(i.uv[1], i.uv[2]);
				float dotDistance2 = NormalDotDistance(i.uv[3], i.uv[4]);

				dotDistance = (dotDistance + dotDistance2) / 2;
	
				return fixed4(dotDistance, dotDistance, dotDistance, 1);
			}
			ENDCG
		}
	}
}
