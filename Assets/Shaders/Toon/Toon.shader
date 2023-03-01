Shader "Master/Toon"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass    // 黑色描边
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
                float3 worldPos : TEXCOORD1;
            };

            float4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;

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
            Cull Back
            
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

            float4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct  v2f
            {
                float3 worldNormal : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                // 裁剪空间中的顶点位置
                o.pos = UnityObjectToClipPos(v.vertex);
                // 表面法线
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // 算出顶点在世界空间的位置
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                
                // 顶点到光源方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 颜色分段
                // float NdotL = saturate(dot(i.worldNormal, worldLight)); // 兰伯特模型
                float NdotL = 0.5 + 0.5 * dot(i.worldNormal, worldLightDir);   // "半兰伯特"模型
                if(NdotL > 0.6)
                    NdotL = 1;
                else if (NdotL > 0.2)
                    NdotL = 0.3;
                else
                    NdotL = 0.1;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * NdotL;

                // 反射方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                // 照相机方向（视线方向）
                fixed3 viewDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                // 高光反射
                float spec = pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                if(spec > 0.001)
                    spec = 1;
                else
                    spec = 0;

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * spec;

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    
    
}