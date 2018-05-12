// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/CommonShader"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)

	 _MainTex ("Texture", 2D) = "white" {}
	_BumpMap("Normal Map", 2D) = "bump" {}
	_OcclusionMap("Occlusion", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  "Queue" = "Background" "IgnoreProjector" = "Ture" }
		LOD 100

		Pass
		{
			Name "MY_FORWARDBASE"
			Tags{ "LightMode" = "ForwardBase" }
			Cull Off
			//Blend SrcAlpha OneMinusSrcAlpha
		//ZWrite Off
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

				//for normalmap
				// that transforms from tangent to world space
				half3 tspace0 : TEXCOORD1; // tangent.x, bitangent.x, normal.x
				half3 tspace1 : TEXCOORD2; // tangent.y, bitangent.y, normal.y
				half3 tspace2 : TEXCOORD3; // tangent.z, bitangent.z, normal.z
											// texture coordinate for the normal map
				float2 uv : TEXCOORD4;
				float4 pos : SV_POSITION;

				//for light
				fixed4 diff : COLOR0; // diffuse lighting color
				fixed4 ambient : COLOR1;


				//for shadow
				SHADOW_COORDS(5) // put shadows data into TEXCOORD1

			};

			// vertex shader now also needs a per-vertex tangent vector.
			// in Unity tangents are 4D vectors, with the .w component used to
			// indicate direction of the bitangent vector.
			// we also need the texture coordinate.
			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
			{
				v2f o;
				
				o.pos = mul(UNITY_MATRIX_MVP, vertex);
				o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;
				
				//for normal
				half3 wNormal = UnityObjectToWorldNormal(normal);
				half3 wTangent = UnityObjectToWorldDir(tangent.xyz);
				// compute bitangent from cross product of normal and tangent
				half tangentSign = tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				// output the tangent space matrix
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
				o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
				o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);


				o.uv = uv;

				// dot product between normal and light direction for
				// standard diffuse (Lambert) lighting
				half nl = max(0, dot(wNormal, _WorldSpaceLightPos0.xyz));
				// factor in the light color

				o.diff = nl * _LightColor0;

				// the only difference from previous shader:
				// in addition to the diffuse lighting from the main light,
				// add illumination from ambient or light probes
				// ShadeSH9 function from UnityCG.cginc evaluates it,
				// using world space normal
				o.ambient.rgb = ShadeSH9(half4(wNormal, 1));


				// compute shadows data
				TRANSFER_SHADOW(o)

				return o;
			}

			// normal map texture from shader properties
			sampler2D _BumpMap;
			sampler2D _MainTex;
			sampler2D _OcclusionMap;

			fixed4 _Color;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed shadow = SHADOW_ATTENUATION(i);

				// sample the normal map, and decode from the Unity encoding
				half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				
				// transform normal from tangent to world space
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tnormal);
				worldNormal.y = dot(i.tspace1, tnormal);
				worldNormal.z = dot(i.tspace2, tnormal);

				// rest the same as in previous shader
				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 worldRefl = reflect(-worldViewDir, worldNormal);
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
				half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
				fixed4 c = 0;
	
				//baseColor
				fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
				fixed occlusion = tex2D(_OcclusionMap, i.uv).r;

				c.rgb = _Color;

				c.rgb *= baseColor;
				c.rgb *= skyColor;
				c.rgb *= occlusion;

				//half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				//fixed4 diff = nl * _LightColor0;
				fixed4 diff = i.diff;

				c.rgb *= diff * shadow + i.ambient;

				//vertex diffuse light
				//c.rgb *= i.diff * shadow + i.ambient;


				//c.rgb *= 0.5 * shadow + i.ambient;		
				return c;
			}
			ENDCG
		} //normal pass end


		//UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

		// shadow caster rendering pass, implemented manually
		// using macros from UnityCG.cginc
			Pass
			{
				Tags{ "LightMode" = "ShadowCaster" }

						CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_shadowcaster
		#include "UnityCG.cginc"

					struct v2f {
						V2F_SHADOW_CASTER;
					};

					v2f vert(appdata_base v)
					{
						v2f o;
						TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
							return o;
					}

					float4 frag(v2f i) : SV_Target
					{
						SHADOW_CASTER_FRAGMENT(i)
					}
				ENDCG
			}

	}
}
