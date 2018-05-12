Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_FluLightTex ("Flu Texture", 2D) = "white" {}
		_FleOffset("", range(0, 2)) = 0

		_FluInstensity("", range(0, 1)) = 0
		_ShowHeight("Show Line Height", Float) = 0
		_HeightFactor("Show Line Height Factor", Float) = 1

	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		Pass
		{

			Blend SrcAlpha OneMinusSrcAlpha

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
				float distance2: TEXCOORD2;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _FluLightTex;
			float4 _FluLightTex_ST;


			fixed4 _Color;

			float _FleOffset;
			float _FluInstensity;

			float _ShowHeight;
			float _HeightFactor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			//	o.distance2 = si worldPos.y - _ShowHeight;

				///o.distance2 = saturate(o.distance2 * _HeightFactor);

				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				float2 flowuv = i.uv;
				flowuv.x /=10;
				flowuv.x += _Time.y * _FleOffset;

				float flow = tex2D(_FluLightTex, flowuv).a;

				fixed4 c;
				c = _Color;

				c *= col;
				c.rgb += float3(flow, flow, flow) * _FluInstensity;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, c);
				return c;

			}
			ENDCG
		}
	}
}
