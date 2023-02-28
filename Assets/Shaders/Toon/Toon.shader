Shader "Master/Toon"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            // 正面剔除
            Cull Front
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            float4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;

                // 顶点偏移方便查看结果
                // o.pos.x += 0.5;

                // 获取法线
                float3 normal = v.normal;
                // 顶点加一点法线，以扩大边缘
                v.vertex.xyz += normal * 0.02;

                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return fixed4(0, 0, 0, 1);
            }
            ENDCG
        }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            float4 _Diffuse;

            struct  v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;

                // 裁剪空间中的顶点位置
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // // 环境光
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // // 表面法线
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                
                // // 顶点到光源方向
                // fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                //
                // // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                // // 颜色分段
                // float NdotL = saturate(dot(worldNormal, worldLight));
                // if(NdotL > 0.9)
                //     NdotL = 1;
                // else if (NdotL > 0.5)
                //     NdotL = 0.6;
                // else
                //     NdotL = 0;
                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * NdotL;
                //
                // o.color = ambient + diffuse;
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 顶点到光源方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));
                // 颜色分段
                // float NdotL = saturate(dot(i.worldNormal, worldLight)); // 兰伯特模型
                float NdotL = 0.5 + 0.5 * dot(i.worldNormal, worldLight);   // "半兰伯特"模型
                if(NdotL > 0.9)
                    NdotL = 1;
                else if (NdotL > 0.5)
                    NdotL = 0.6;
                else
                    NdotL = 0;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * NdotL;

                return fixed4(ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
    
    
}