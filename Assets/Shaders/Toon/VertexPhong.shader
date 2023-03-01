Shader "Master/VertexPhong"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
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

            struct  v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;

                // MVP转换
                o.pos = UnityObjectToClipPos(v.vertex);

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 算出世界空间的法线
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // 获取光照方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                // 反射方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

                // 照相机方向（视线方向）
                fixed3 viewDir = normalize(_WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

                // 高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0f);
            }

            ENDCG
        }
    }
    
    Fallback "Specular"
}