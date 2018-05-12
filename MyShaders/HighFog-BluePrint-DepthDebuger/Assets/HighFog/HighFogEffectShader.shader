// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/HighFogEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_FogColor("Fog Color", Color) =  (1,1,1,1)
		_FogHight("Fog Hight", Float) = -1.5
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

			sampler2D_float _CameraDepthTexture;

			half4 _CameraDepthTexture_ST;
			float4x4 _CameraTRS;

			float4 _CameraForward;

			//porpert


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;

				float4 vertex : SV_POSITION;

				float h: TEXCOORD1;
				float3 worldPos: TEXCOORD2;
			};


			//function
			//screen V Pos form (0, 0) to (1, 1) --- from left down corner to right up corner
			float3 MyScreenPointToRay(float2 scrV)
			{
			// the graphic bit  will draw a rect (-1, 1)
				float2 scrPixel = float2 (_ScreenParams.x / 2* scrV.x, _ScreenParams.y / 2* scrV.y);// - (_ScreenParams.xy / 2);

				float distanceToPlane =  _ScreenParams.y * 0.5 / tan(radians(30));	//radians(60)
				//return float4(scrPixel.x, scrPixel.y, distanceToPlane, 1).xyz;
				return mul( _CameraTRS , float4(scrPixel.x, scrPixel.y, distanceToPlane, 1)).xyz;
			}


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				//mul(unity_ObjectToWorld, v.vertex).xyz
				o.worldPos = o.vertex.xyz;//MyScreenPointToRay(o.vertex.xy);	// - float3(0.5, 0.5, 0);
				// o.uv = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;//UnityStereoScreenSpaceUVAdjust(v.uv.xy, _CameraDepthTexture_ST);
				//o.uv = o.vertex;
				return o;
			}
			
			sampler2D _MainTex;
			fixed4 _FogColor;
			float _FogHight;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				//col = 1 - col;


				//ScreenPointToRay

				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, float2(i.uv.x, 1 - i.uv.y));
				d = LinearEyeDepth(d); //real world distance
				//d = Linear01Depth(d); //map to 0~1

				float CameraH = _WorldSpaceCameraPos.y;

				//
				float3 ray = MyScreenPointToRay(i.worldPos.xy);
				float3 up = float3(0, 1, 0);

				//camera's forward
				float3 forward =_CameraForward.xyz;// unity_CameraWorldClipPlanes[4];//float3(0, 0, 1);


				float adotb1 = dot(ray, forward);
				float cosa1 = adotb1 / (length(forward) * length(ray)); 

				float l = d / cosa1;//cos(radians(30));


				float adotb = dot(ray, up);
				float cosa = adotb / (length(up) * length(ray)); 

				float h1 = cosa * l + CameraH;
				//float h1 = cosa * l;

//				if (h1 > 0)
//				{
//					return col;
//				}
				float aa = saturate(exp(-(l - 100) / 1000));
				//return fixed4 (aa, 0, 0 , 1);
				//return fixed4(ray.x / 550, 0, 0,  1);
				float a = 0;
				if (h1 < _FogHight)
				{	a = _FogHight - h1;
					a = saturate( a / 10);

					return fixed4(lerp(col.rgb, _FogColor.rgb, a * aa), 1);
				}
				//col += fixed4(_FogColor.xyz, a) / 6;// _FogColor.w *

				return col;
				//fixed4 a = unity_CameraWorldClipPlanes[4];
				//return half4( + h1, 0, 0,  1);
				//return half4(ray.z,0, 0, 1);
				//return a* 0.9;
				//return fixed4(a.w, 0, 0, 1);
			}
			ENDCG
		}
	}
}
