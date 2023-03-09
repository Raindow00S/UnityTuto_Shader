Shader "Master/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Distance ("Distance", Range(0, 0.1)) = 0
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
            float _Distance;

            fixed GetNeighborLuminance(v2f i, float h, float v)
            {
                fixed4 col = tex2D(_MainTex, float2(i.uv.x + h * _Distance, i.uv.y + v * _Distance));
                return 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed crtL = GetNeighborLuminance(i, 0, 0);
                fixed topL = GetNeighborLuminance(i, 0, 1);
                fixed bottomL = GetNeighborLuminance(i, 0, -1);
                fixed leftL = GetNeighborLuminance(i, -1, 0);
                fixed rightL = GetNeighborLuminance(i, 1, 0);
                fixed topRightL = GetNeighborLuminance(i, 1, 1);
                fixed bottomRightL = GetNeighborLuminance(i, 1, -1);
                fixed bottomLeftL = GetNeighborLuminance(i, -1, -1);
                fixed topLeftL = GetNeighborLuminance(i, -1, 1);
                // 获取八个方向间隔的像素颜色


                // 两次卷积：水平和垂直   // sobel算子
                half edgeX = topLeftL * -1 + topL * 0 + topRightL * 1 + leftL * -2 + crtL * 0 + rightL * 2 + bottomLeftL * -1 + bottomL * 0 + bottomRightL * 1;
                half edgeY = topLeftL * -1 + topL * -2 + topRightL * -1 + leftL * 0 + crtL * 0 + rightL * 0 + bottomLeftL * 1 + bottomL * 2 + bottomRightL * 1;
                half edge = abs(edgeX) + abs(edgeY);
                
                return lerp(float4(1, 1, 1, 1), float4(0, 0, 0, 1), edge);
            }
            
            ENDCG
        }
    }
}
