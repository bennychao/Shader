// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyGlow/MovablePointLight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Range("Point Lit Range", Float) = 0.5

			_MovePoint("move point", Vector) = (0, 0, 0, 1)
			_MoveDir("move dir", Vector) = (0, 1, 0, 1)
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
				float distance2: TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Range;

			uniform float4 _MovePoint;
			uniform float4 _MoveDir;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				float3 tmpVec = worldPos - _MovePoint.xyz;

				float tlen = distance(worldPos, _MovePoint.xyz);
				float dlen = length(_MoveDir);
				//float r = saturate(  / _Range);

				float fDot = dot(tmpVec, _MoveDir.xyz);

				//cos a = dot / tlen * dlen

				o.distance2 = fDot   / (dlen * _Range);

				//if (fDot < 0)
				//{
				//	o.distance2 = -o.distance2;
				//}


				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				//if (i.distance > 0)
				//	col = fixed4(i.distance, 0, 0, 1);
				//else
				//	col = fixed4(0, -i.distance, 0, 1);
				fixed c = 1- i.distance2;
				if (i.distance2  > 0)
					col = fixed4(c, 0, 0, 1);
				else
					col = fixed4(1 + i.distance2, 0, 0, 1);
				return col;
			}
			ENDCG
		}
	}
}
