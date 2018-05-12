Shader "Unlit/EdgeGlow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_EdgePower("Edge Power", Float) = 1.0
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

				fixed3 worldPos = mul(_Object2World, v.vertex).xyz;

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
	}
}
