Shader "Master/SpriteShader/Gray"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _GrayFactor ("GrayFactor", Range(0, 1)) = 1
    }
    SubShader
    {
//        Tags
//        {
//            "Queue" = "Transparent"
//        }
        
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _GrayFactor;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                // col.rgb = 1 - col.rgb;

                fixed4 grayCol = col.r * 0.299 + col.g * 0.587 + col.b * 0.114;
                col = lerp(col, grayCol, _GrayFactor);
                
                return col;
            }
            ENDCG
        }
    }
}
