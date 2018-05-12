// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyGlow/EdgeGlowAddMovablePointLit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_EdgePower("Edge Power", Float) = 1.0

		_Range("Point Lit Range", Float) = 0.5
		_Width("Point Lit Width", Float) = 0.5
		_MovePoint("move point", Vector) = (0, 0, 0, 1)
		_MoveDir("move dir", Vector) = (0, 1, 0, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "Edge Glow"

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
				fixed3 normal : TEXCOORD1;

				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;


				fixed4 edgeEmssion : COLOR0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _EdgeColor;
			float _EdgePower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				half3 wNormal = UnityObjectToWorldNormal(v.normal);
				half rim = 1.0 - saturate(dot(normalize(worldViewDir), wNormal));


				fixed4 tmpColor = _EdgeColor * pow(rim, _EdgePower);
				float alpha = saturate(tmpColor.w );
				o.edgeEmssion = fixed4(tmpColor.xyz, alpha);

				o.normal = v.normal;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col += i.edgeEmssion;

	

				col = fixed4(col.xyz, col.z * (1 - i.edgeEmssion.w))

				//col = fixed4(col.xyz, 0.5);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}



		Pass
		{
			Name "movable point lit"

			Blend One one

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
				float distance2 : TEXCOORD2;

				float range : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Range;
			float _Width;

			uniform float4 _MovePoint;
			uniform float4 _MoveDir;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				float3 tmpVec = worldPos - _MovePoint.xyz;

				float tlen = distance(worldPos, _MovePoint.xyz);
				o.range = tlen;
				//if (tlen > _Range)
				//{
				//	o.distance2 = 1;
				//}
				//else
				{
					float dlen = length(_MoveDir);
					//float r = saturate(  / _Range);

					float fDot = dot(tmpVec, _MoveDir.xyz);

					//cos a = dot / tlen * dlen

					o.distance2 = fDot / (dlen * _Width);
				}


				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{


				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
			// apply fog
			UNITY_APPLY_FOG(i.fogCoord, col);


			if (i.range > _Range)
			{
				col = fixed4(0, 0, 0, 0);
				return col;
			}

			//if (i.distance > 0)
			//	col = fixed4(i.distance, 0, 0, 1);
			//else
			//	col = fixed4(0, -i.distance, 0, 1);
			fixed c = 1 - i.distance2;
			if (i.distance2  > 0)
				col = fixed4(c, 0, 0, c);
			else
				col = fixed4(1 + i.distance2, 0, 0, 1 + i.distance2);
			return col;
			}
				ENDCG
			}
	}
}
