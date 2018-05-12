Shader "Unlit/VolumeShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="geometry"}
		LOD 100

		//pass 0 render the backward face
		Pass
		{

			//[TODO] 
			//ColorMask RGB 
			CULL Front
			//ZTest Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;

				float depth : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

//			sampler2D_float _CameraDepthTexture;
//			half4 _CameraDepthTexture_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);

				//get depth 0 ~ 1
				o.depth = o.vertex.w / _ProjectionParams.z;

				return o;
			}

			
			fixed4 frag (v2f i) : SV_Target1
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return fixed4(i.depth, 0, 0, 1);
			}
			ENDCG
		}


		//pass 0 render the forward face
		Pass
		{

			//[TODO] 
			//ColorMask RGB 


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;

				float depth : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

//			sampler2D_float _CameraDepthTexture;
//			half4 _CameraDepthTexture_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);

				//get depth 0 ~ 1
				o.depth = o.vertex.w / _ProjectionParams.z;

				return o;
			}

			
			fixed4 frag (v2f i) : SV_Target0
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return fixed4(i.depth, 0, 0, 1);
			}
			ENDCG
		}




	}
}
