Shader "Unlit/WaveDeformer"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Frequency ("Frequency", FLOAT) = 1
		_WaveOffset("Wave Offset", FLOAT) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{

			CULL OFF
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
				float color1: TEXCOORD1;
				float4 wordPos : TEXCOORD2;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Frequency;
			float _WaveOffset;
			
			v2f vert (appdata v)
			{
				v2f o;

				float4 vtmp = v.vertex;
				//float sind = sqrt(vtmp.x * vtmp.x + (vtmp.z* vtmp.z)) * _Frequency + _WaveOffset;// + _Time.z;
//				float sind = vtmp.y * _Frequency + _WaveOffset + _Time.z;
//				float y = saturate((sin(sind) - 0.999)* 1000);

				o.wordPos = mul(_Object2World, v.vertex);

				//o.color1 = y;
				//vtmp.y = y;
				//vtmp.w = 0;
				o.vertex = mul(UNITY_MATRIX_MVP, vtmp);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);


				float sind = (i.wordPos.y + i.wordPos.z)* _Frequency + _WaveOffset + _Time.z;
				float y = saturate((sin(sind) - 0.99)* 90);


				col += y;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
