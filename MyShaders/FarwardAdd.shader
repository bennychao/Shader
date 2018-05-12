Shader "Unlit/FarwardAdd"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)

		_MainTex("Texture", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector" = "Ture" }
		LOD 200



		Pass
			{
				Name "MY_FORWARDBASE"
				Tags{ "LightMode" = "ForwardBase" }
		//Blend One One
				CGPROGRAM


#pragma vertex vert
#pragma fragment frag

				// make fog work
#pragma multi_compile_fog

#pragma multi_compile_fwdbase

#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc" // for _LightColor0

#include "AutoLight.cginc"

			struct v2f {
				float3 worldPos : TEXCOORD0;
				// these three vectors will hold a 3x3 rotation matrix
				float2 uv : TEXCOORD4;
				float4 pos : SV_POSITION;

				//for light
				fixed4 diff : COLOR0; // diffuse lighting color
				fixed4 ambient : COLOR1;

				//for shadow
				SHADOW_COORDS(5) // put shadows data into TEXCOORD1

			};

			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, vertex);
				o.worldPos = mul(_Object2World, vertex).xyz;

				//for normal
				half3 wNormal = UnityObjectToWorldNormal(normal);

				o.uv = uv;

				// dot product between normal and light direction for
				// standard diffuse (Lambert) lighting
				half nl = max(0, dot(wNormal, _WorldSpaceLightPos0.xyz));
				// factor in the light color

				o.diff = nl * _LightColor0;

				o.ambient.rgb = ShadeSH9(half4(wNormal, 1));


				// compute shadows data
				TRANSFER_SHADOW(o)

				return o;
			}

			// normal map texture from shader properties
			sampler2D _MainTex;

			fixed4 _Color;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed shadow = SHADOW_ATTENUATION(i);
			//baseColor
			fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
			fixed4 c;
			c.rgb = _Color;

			c.rgb *= baseColor;

			fixed4 diff = i.diff;

			c.rgb *= diff * shadow + i.ambient;
			return c;
			}
				ENDCG
			} //normal pass end


		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

		Pass
			{
				Name "MY_FORWARDADD"
				Tags{ "LightMode" = "ForwardAdd" }
				Blend One One
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
				// make fog work
#pragma multi_compile_fog

				//for fwdbase
#pragma multi_compile_fwdadd
#include "UnityCG.cginc"


#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;

				float3 normal : TEXCOORD1;
				float3 worldPos: TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.worldPos = mul(_Object2World, v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				//o.normal = v.normal;

				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

			fixed4 ret = col;

			fixed3 wNormal = i.normal;// UnityObjectToWorldNormal(i.normal);

									  // dot product between normal and light direction for
									  // standard diffuse (Lambert) lighting
			fixed3 lightDir = _WorldSpaceLightPos0.xyz - i.worldPos;

			half nl = max(0, dot(wNormal, normalize(lightDir)));		//normalize！！！
																		// factor in the light color

			fixed4 diff = nl * _LightColor0;

			ret *= diff;

			// apply fog
			UNITY_APPLY_FOG(i.fogCoord, col);
			return ret;
			}
				ENDCG
			}
		//UsePass "Unlit/NewUnlitShader 1/MY_FORWARDBASE"
	}
}
