Shader "Unlit/BluePrintObject2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Layer("Layer", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		CULL OFF

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


			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Layer;

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
		
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 suv = float2(i.vertex.x / _ScreenParams.x, i.vertex.y / _ScreenParams.y);

				float depth = i.vertex.w / _ProjectionParams.z;

				fixed4 col = EncodeDepthNormal(depth, i.normal);

				if (_Layer == 0)
				{
					return col;
				}
				else
				{
					//for test show
					fixed4 col1 = tex2D(_MainTex, suv);
					//return fixed4(1, 0, 0, 1);
					//return col1;

					float d1 = 0; 
					float3 normalout1;
					DecodeDepthNormal(col1, d1, normalout1);

					// for test show
					//return fixed4(depth, d1, 0, 1);
					//return fixed4(normalout1, 1);

					//check depth
					if (depth <= (d1 + 0.00001))
					{
						discard;
						return fixed4(1, 0, 0, 1);
					}
					else
					{
						return col;
					}

				}

				//return fixed4(i.suv, 0 ,1 );
				//return fixed4(, 0 ,1);
			}
			ENDCG
		}
	}
}
