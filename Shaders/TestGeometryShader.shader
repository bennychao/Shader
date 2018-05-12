Shader  "Citrus/Sea2"
    {    
    Properties

    {

//           _FaceColor("Face Color",Color) = (1,1,1,1)//面向光源显示的颜色
//
//           _BackColor("Back Color",Color) = (1,1,1,1)//背向光源显示的颜色

           _MainTex("Main Texture",2D) = "white" {} //主贴图
           _NoiseMap("Noise map", 2D) = "white"{}
//
//           _NormalMap("Normal Map",2D) = "bump"{}//控制海面挪动的发现图
//
//           _Hightness("Hightness",Float) = 1//调节海面的挪动高度
//
//           _TimeRate("Time Rate",Float) = 1//控制海面的挪动频率

     }

     SubShader

     {

          Pass

          {   

               Tags{"RenderType" = "Opaque" "Queue" =  "Gepmetry"}

               LOD 200

               CGPROGRAM

               # pragma 4.0

               #include "UnityCG.cginc"

               #include "Lighting.cginc"

              #include "AutoLight.cginc"

              //定义顶点着色器

              #pragma vertex vert

              //定义片段着色器

             #pragma fragment frag

             //定义几何着色器

             #pragma geometry geom

             

              struct a2v

              {

                      float4 vertex : POSITION;//模型顶点位置

//                      float3 normal : NORMAL;//模型法线
//
                      float4 texcoord : TEXCOORD0;//输入的坐标纹理集
//
//                      float4 tangent : TANGENT;//模型切线

              };

              struct v2g

             {

                     float4 pos :POSITION;//顶点位置

                     float2 uv :TEXCOORD0;//坐标纹理集

                     //float3 lightDir : TEXCOORD1;//光照方向

             }; 

             struct g2f

             {

                     float4 pos : POSITION;//位置信息

                     float2 uv : TEXCOORD0;//坐标纹理集

                    // float3 diffColor:TEXCOORD1;//输出颜色

             };

             float4  _MainTex_ST;

             sampler2D _MainTex;
             sampler2D _NoiseMap;

//             float4  _NormalMap_ST;
//
//             sampler2D _NormalMap;
//
//             float _TimeRate;
//
//             float _Hightness;
//
//             fixed4 _FaceColor;
//
//             fixed4 _BackColor;

             

             

             v2g vert(a2v v)

             {

                 v2g output;

                // float d2 = tex2Dlod(_NormalMap,float4(v.texcoord.xy+_Time.x*_TimeRate,0,0)).r;//海水根据时间抖动高度

                 output.pos = mul(UNITY_MATRIX_MVP,v.vertex);// + float4(0,d2,0,0)*_Hightness;//平面顶点位置

                 output.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

//                 float3 binormal = cross(v.normal,v.tangent.xyz) * v.tangent.w;//副法线
//
//                 float3x3 rotation = float3x3(v.tangent.xyz , binormal , v.normal );//自身矩阵

                 //output.lightDir = normalize(mul(UNITY_MATRIX_MVP,mul(rotation , ObjSpaceLightDir(v.vertex))));//光照方向

                 return output;

            }

            

           [maxvertexcount(4)]
           void geom (triangle v2g p[3] , inout TriangleStream<g2f> triStream)
           {
                 //屏幕坐标的顶点位置
//                 float3 p0 = p[0].pos.xyz;
//                 float3 p1 = p[1].pos.xyz;
//                 float3 p2 = p[2].pos.xyz;
//                 //三角形三条边的矢量方向
//                 float3 v0 = p2  - p1;
//                 float3 v1 = p2  - p0;
//                 float3 v2 = p1 - p0;
//                 //计算三角形的法线
//                 float3  trianglenormal = normalize(cross(v1,v2));
//                 //计算三角形的光照方向
//                 float3  triangleLightDir = normalize( p[ 0 ].lightDir + p[1].lightDir + p[2].lightDir);
//                 float  diff = max(dot(trianglenormal,triangleLightDir),0);
                 g2f  pIn;
                 //pIn.diffColor = lerp(_FaceColor,_BackColor,diff);
                 //输入第一个点


                 float4 texColor = tex2D(_MainTex,p[0].uv);
                 pIn.pos = p[0].pos;
                 pIn.uv = p[0].uv + texColor.xy;
                 triStream.Append(pIn);
      
                 //输入第二个点
                 pIn.pos = p[1].pos;
                 pIn.uv = p[1].uv;
                 triStream.Append(pIn);
      
                 //输入第三个点
                pIn.pos = p[2].pos;
                pIn.uv = p[2].uv;
                triStream.Append(pIn);
            }
            
            float4 frag(g2f  input):COLOR
           {
                 float4 texColor = tex2D(_MainTex,input.uv);// + _Time.x);

                 //texColor = noise(input.uv);
                 return texColor;//float4(input.diffColor,1) * texColor ;
           }
           ENDCG
          }

     }

    }