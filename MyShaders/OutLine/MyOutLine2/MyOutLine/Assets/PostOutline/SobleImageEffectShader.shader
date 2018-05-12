Shader "Hidden/SobleImageEffectShader"
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


			sampler2D _MainTex;

			uniform half4 _MainTex_TexelSize;
			half4 _MainTex_ST;


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
			
				half2 coords = i.uv.xy;

				// just invert the colors
				//col = 1 - col;
				
				half4 v00 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(-1.0, -1.0), _MainTex_ST));
				half4 v01 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(0, -1.0), _MainTex_ST));
				half4 v02 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(1.0, -1.0), _MainTex_ST));

				half4 v20 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(-1.0, 1.0), _MainTex_ST));
				half4 v21 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(0, 1.0), _MainTex_ST));
				half4 v22 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(1.0, 1.0), _MainTex_ST));
				
				//half4 v00 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(-1.0, -1.0), _MainTex_ST));
				half4 v10 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(-1.0, 0.0), _MainTex_ST));
				//half4 v20 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(-1.0, 1.0), _MainTex_ST));

				//half4 v02 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(1.0, -1.0), _MainTex_ST));
				half4 v12 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(1.0, 0), _MainTex_ST));
				//half4 v22 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords + _MainTex_TexelSize.xy * half2(1.0, 1.0), _MainTex_ST));

				half m = abs(v20 + (v21 * 2) + v22 - v00 - (v01* 2) - v02) + abs(v22 + (v12 * 2) + v02 - v00 - (v10 * 2) - v20);

				//- half4(0.5f, 0.5f, 0.5f, 0)
				return m ;
			}
			ENDCG
		}
	}
}
