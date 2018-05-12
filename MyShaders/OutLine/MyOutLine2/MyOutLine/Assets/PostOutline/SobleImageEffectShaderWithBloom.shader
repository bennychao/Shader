
Shader "Hidden/SobleFastBloom" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//_OutlineColor("Out line Color", Color) = (1, 0, 1, 1)
		_Bloom ("Bloom (RGB)", 2D) = "black" {}
	}
	
	CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _Bloom;
				
		uniform half4 _MainTex_TexelSize;
		half4 _MainTex_ST;
		
		uniform half4 _Parameter;
		uniform half4 _OffsetsA;
		uniform half4 _OffsetsB;

		uniform fixed4 _OutlineColor;
		
		#define ONE_MINUS_THRESHHOLD_TIMES_INTENSITY _Parameter.w
		#define THRESHHOLD _Parameter.z

		struct v2f_simple 
		{
			float4 pos : SV_POSITION; 
			half2 uv : TEXCOORD0;

        #if UNITY_UV_STARTS_AT_TOP
				half2 uv2 : TEXCOORD1;
		#endif
		};	
		
		v2f_simple vertBloom ( appdata_img v )
		{
			v2f_simple o;
			
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
        	o.uv = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
        	
        #if UNITY_UV_STARTS_AT_TOP
        	o.uv2 = o.uv;
        	if (_MainTex_TexelSize.y < 0.0)
        		o.uv.y = 1.0 - o.uv.y;
        #endif
        	        	
			return o; 
		}

		struct v2f_tap
		{
			float4 pos : SV_POSITION;
			half2 uv20 : TEXCOORD0;
			half2 uv21 : TEXCOORD1;
			half2 uv22 : TEXCOORD2;
			half2 uv23 : TEXCOORD3;
		};			

		v2f_tap vert4Tap ( appdata_img v )
		{
			v2f_tap o;

			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
        	o.uv20 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy, _MainTex_ST);
			o.uv21 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h,-0.5h), _MainTex_ST);
			o.uv22 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy * half2(0.5h,-0.5h), _MainTex_ST);
			o.uv23 = UnityStereoScreenSpaceUVAdjust(v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h,0.5h), _MainTex_ST);

			return o; 
		}					
						
		fixed4 fragBloom ( v2f_simple i ) : SV_Target
		{	
        	#if UNITY_UV_STARTS_AT_TOP
			
			fixed4 color = tex2D(_MainTex, i.uv2);
			return color + tex2D(_Bloom, i.uv);
			
			#else

			fixed4 color = tex2D(_MainTex, i.uv);
			return color + tex2D(_Bloom, i.uv);
						
			#endif
		} 
		
		fixed4 fragDownsample ( v2f_tap i ) : SV_Target
		{				
			fixed4 color = tex2D (_MainTex, i.uv20);
			//color += tex2D (_MainTex, i.uv21);
			//color += tex2D (_MainTex, i.uv22);
			//color += tex2D (_MainTex, i.uv23);
			//return max(color/4 - THRESHHOLD, 0) * ONE_MINUS_THRESHHOLD_TIMES_INTENSITY;

			return _OutlineColor * (1 - color.w) * ONE_MINUS_THRESHHOLD_TIMES_INTENSITY;
		}
	
		// weight curves

		static const half curve[7] = { 0.0205, 0.0855, 0.232, 0.324, 0.232, 0.0855, 0.0205 };  // gauss'ish blur weights

		static const half4 curve4[7] = { half4(0.0205,0.0205,0.0205,0), half4(0.0855,0.0855,0.0855,0), half4(0.232,0.232,0.232,0),
			half4(0.324,0.324,0.324,1), half4(0.232,0.232,0.232,0), half4(0.0855,0.0855,0.0855,0), half4(0.0205,0.0205,0.0205,0) };

		struct v2f_withBlurCoords8 
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
			half2 offs : TEXCOORD1;
		};	
		
		struct v2f_withBlurCoordsSGX 
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half4 offs[3] : TEXCOORD1;
		};

		v2f_withBlurCoords8 vertBlurHorizontal (appdata_img v)
		{
			v2f_withBlurCoords8 o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);
			o.offs = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _Parameter.x;

			return o; 
		}
		
		v2f_withBlurCoords8 vertBlurVertical (appdata_img v)
		{
			v2f_withBlurCoords8 o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);
			o.offs = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _Parameter.x;
			 
			return o; 
		}	

		half4 fragBlur8 ( v2f_withBlurCoords8 i ) : SV_Target
		{
			half2 uv = i.uv.xy; 
			half2 netFilterWidth = i.offs;  
			half2 coords = uv - netFilterWidth * 3.0;  
			
			half4 color = 0;
  			for( int l = 0; l < 7; l++ )  
  			{   
				half4 tap = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(coords, _MainTex_ST));
				color += tap * curve4[l];
				coords += netFilterWidth;
  			}
			return color;
		}


		v2f_withBlurCoordsSGX vertBlurHorizontalSGX (appdata_img v)
		{
			v2f_withBlurCoordsSGX o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = v.texcoord.xy;

			half offsetMagnitude = _MainTex_TexelSize.x * _Parameter.x;
			o.offs[0] = v.texcoord.xyxy + offsetMagnitude * half4(-3.0h, 0.0h, 3.0h, 0.0h);
			o.offs[1] = v.texcoord.xyxy + offsetMagnitude * half4(-2.0h, 0.0h, 2.0h, 0.0h);
			o.offs[2] = v.texcoord.xyxy + offsetMagnitude * half4(-1.0h, 0.0h, 1.0h, 0.0h);

			return o; 
		}		
		
		v2f_withBlurCoordsSGX vertBlurVerticalSGX (appdata_img v)
		{
			v2f_withBlurCoordsSGX o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);

			half offsetMagnitude = _MainTex_TexelSize.y * _Parameter.x;
			o.offs[0] = v.texcoord.xyxy + offsetMagnitude * half4(0.0h, -3.0h, 0.0h, 3.0h);
			o.offs[1] = v.texcoord.xyxy + offsetMagnitude * half4(0.0h, -2.0h, 0.0h, 2.0h);
			o.offs[2] = v.texcoord.xyxy + offsetMagnitude * half4(0.0h, -1.0h, 0.0h, 1.0h);

			return o; 
		}	

		half4 fragBlurSGX ( v2f_withBlurCoordsSGX i ) : SV_Target
		{
			half2 uv = i.uv.xy;
			
			half4 color = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST)) * curve4[3];
			
  			for( int l = 0; l < 3; l++ )  
  			{   
				half4 tapA = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.offs[l].xy, _MainTex_ST));
				half4 tapB = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.offs[l].zw, _MainTex_ST));
				color += (tapA + tapB) * curve4[l];
  			}

			return color;

		}	
					
	ENDCG
	
	SubShader {
	  ZTest Off Cull Off ZWrite Off Blend Off
	  		Stencil {
	            Ref 2
	            Comp NotEqual
	            Pass keep 
	            //ZFail decrWrap
	        }

	// 0
	Pass {
	
		CGPROGRAM
		#pragma vertex vertBloom
		#pragma fragment fragBloom
		
		ENDCG
		 
		}

	// 1
	Pass { 
	
		CGPROGRAM
		
		#pragma vertex vert4Tap
		#pragma fragment fragDownsample
		
		ENDCG
		 
		}

	// 2
	Pass {
		ZTest Always
		Cull Off
		
		CGPROGRAM 
		
		#pragma vertex vertBlurVertical
		#pragma fragment fragBlur8
		
		ENDCG 
		}	
		
	// 3	
	Pass {		
		ZTest Always
		Cull Off
				
		CGPROGRAM
		
		#pragma vertex vertBlurHorizontal
		#pragma fragment fragBlur8
		
		ENDCG
		}	

	// alternate blur
	// 4
	Pass {
		ZTest Always
		Cull Off
		
		CGPROGRAM 
		
		#pragma vertex vertBlurVerticalSGX
		#pragma fragment fragBlurSGX
		
		ENDCG
		}	
		
	// 5
	Pass {		
		ZTest Always
		Cull Off
				
		CGPROGRAM
		
		#pragma vertex vertBlurHorizontalSGX
		#pragma fragment fragBlurSGX
		
		ENDCG
		}

			//6 for soble

		Pass
		{


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"


			//sampler2D _MainTex;

			//uniform half4 _MainTex_TexelSize;
			//half4 _MainTex_ST;


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
				fixed4 col = _OutlineColor * m;
				col.w = 1;
			//	col.w = m;
				return col;
			}
			ENDCG
		}	
	}	




	FallBack Off
}
