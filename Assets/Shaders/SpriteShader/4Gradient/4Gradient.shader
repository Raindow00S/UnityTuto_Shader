Shader "Master/SpriteShader/4Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // 渐变四个角的颜色
        _LTColor ("LeftTopColor", Color) = (1, 1, 1, 1)
        _LBColor ("LeftBottomColor", Color) = (1, 1, 1, 1)
        _RTColor ("RightTopColor", Color) = (1, 1, 1, 1)
        _RBColor ("RightBottomColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
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
            fixed4 _LTColor;
            fixed4 _RTColor;
            fixed4 _LBColor;
            fixed4 _RBColor;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float arg = 1;

                // GPU不擅长流程控制，可以用lerp代替if
                fixed4 TL2RColor = lerp(_LTColor, _RTColor, i.uv.x);
                fixed4 BL2RColor = lerp(_LBColor, _RBColor, i.uv.x);
                fixed4 B2TColor = lerp(BL2RColor, TL2RColor, i.uv.y);
                
                col = B2TColor * col;
                
                return col;
            }
            ENDCG
        }
    }
}
