Shader "Unlit/NoiseUV"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		 _NoiseMap("Noise map", 2D) = "white"{}
		 _Frequency ("Frequency", FLOAT) = 1
		 _Speed ("Speed", FLOAT) = 1
		_WaveFactor("Wave Factor", FLOAT) = 100
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
				float xoffset : TEXCOORD1;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Frequency;
			float _WaveFactor;
			float _Speed;
			sampler2D _NoiseMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
//				fixed4 col = tex2D(_MainTex, o.uv);
				fixed2 col2 = tex2D(_NoiseMap, o.uv);
				//o.vertex.x += float(col2.x);
//				float4 col3 = col2;
				//o.uv2 = col2.xy;
//				float xoffset = sin(o.uv.x * _Frequency + _Time.y + col.xy) / _WaveFactor; 
//				o.uv.x += xoffset;


				float xoffset = sin(o.uv.x * _Frequency + (_Speed * _Time.y)) / _WaveFactor;
				o.xoffset = xoffset;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float4 col = tex2D(_NoiseMap, i.uv);

				//float xoffset = sin(i.uv.x * _Frequency + (_Speed * _Time.y)) / _WaveFactor; 
				// apply fog

				fixed4 col2 = tex2D(_MainTex, i.uv + i.xoffset);
				//col2.x += xoffset;
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col2;
			}
			ENDCG
		}
	}
}
