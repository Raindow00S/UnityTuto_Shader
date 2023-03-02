Shader "Master/SpriteShader/Gray"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _GrayFactor ("GrayFactor", Range(0, 1)) = 1
//        _IsReverse ("IsReverse", bool) = false    // shader中不能使用bool
        [Toggle(_IsReverse)] _IsReverse ("IsReverse", float) = 0
        [Toggle(_IsVertical)] _IsVertical ("IsVertical", float) = 0
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
            float _IsReverse;
            float _IsVertical;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                // col.rgb = 1 - col.rgb;

                fixed4 grayCol = col.r * 0.299 + col.g * 0.587 + col.b * 0.114;
                // col = lerp(col, grayCol, _GrayFactor);

                float arg = 1;
                if(_IsVertical == 0)
                    arg = i.uv.x;
                else
                    arg = i.uv.y;
                if(_IsReverse == 1)
                    arg = 1 - arg;
                
                col = lerp(col, grayCol, arg * _GrayFactor);
                
                return col;
            }
            ENDCG
        }
    }
}
