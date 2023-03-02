Shader "Master/SpriteShader/Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // 渐变颜色起始a
        _FromColor ("FromColor", Color) = (1, 1, 1, 1)
        // 渐变结束颜色b
        _ToColor ("ToColor", Color) = (1, 1, 1, 1)
        // 是否反向
        [Toggle(_IsReverse)] _IsReverse ("IsReverse", Int) = 0
        // 水平或竖直方向
        [Toggle(_IsVertical)] _IsVertical ("IsVertical", Int) = 0
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
            // float _GrayFactor;
            fixed4 _FromColor;
            fixed4 _ToColor;
            float _IsReverse;
            float _IsVertical;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float arg = 1;

                // GPU不擅长流程控制，可以用lerp代替if
                arg = lerp(i.uv.x, i.uv.y, _IsVertical);
                arg = lerp(arg, 1 - arg, _IsReverse);
                
                // if(_IsVertical == 0)
                //     arg = i.uv.x;
                // else
                //     arg = i.uv.y;
                // if(_IsReverse == 1)
                //     arg = 1 - arg;
                
                col = lerp(_FromColor, _ToColor, arg) * col;
                
                return col;
            }
            ENDCG
        }
    }
}
