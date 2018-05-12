Shader "Unlit/BluePrintObject"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture", 2D) = "white" {}
		_LayerTex1 ("Layer Tex 1", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		ZWrite On
		//Layer 0
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				half3 normal: TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				half3 wNormal = UnityObjectToWorldNormal(v.normal);
				o.normal = wNormal;
				//o.screen_uv = 
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				UNITY_TRANSFER_DEPTH(o.depth);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			struct fragOut
			{
				fixed4 color :SV_Target;
				//float depth: SV_Depth;
			};
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = EncodeDepthNormal(i.vertex.w / _ProjectionParams.z, i.normal);
			 //col = tex2D(_MainTex, i.uv);
				//col = ComputeScreenPos (i.vertex);
			//	return fixed4(, 0, 0, 1);
				return col;
			}
			ENDCG
		}
//

		//layer 1
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				half3 normal: TEXCOORD2;
				fixed2 suv: TEXCOORD3;

				float4 vertex : SV_POSITION;
			};

			sampler2D _LayerTex1;
			float4 _LayerTex1_ST;

			sampler2D _MainTex;
			float4 _MainTex_ST;
					sampler2D _MainTex2;
			float4 _MainTex2_ST;	
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				half3 wNormal = UnityObjectToWorldNormal(v.normal);
				o.normal = wNormal;
				//o.screen_uv = 
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//get the screen pos
				o.suv = float2(o.vertex.x / _ScreenParams.x, o.vertex.y / _ScreenParams.y);
				//o.suv = ComputeScreenPos (o.vertex)

				//UNITY_TRANSFER_DEPTH(o.depth);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
		
			
			fixed4 frag (v2f i) : SV_Target1
			{
				float2 suv = float2(i.vertex.x / _ScreenParams.x, i.vertex.y / _ScreenParams.y);
				fixed4 col = tex2D(_LayerTex1, i.uv);
				return col;

				//return fixed4(i.suv, 0 ,1 );
				//return fixed4(, 0 ,1);
			}
			ENDCG
		}
	}
}
