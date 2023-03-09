Shader "Master/Sharp"
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

            fixed4 GetNeighborColor(v2f i, float h, float v)
            {
                return tex2D(_MainTex, float2(i.uv.x + h * _Distance, i.uv.y + v * _Distance));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // 获取八个方向间隔的像素颜色
                fixed4 topCol = GetNeighborColor(i, 0, 1);
                fixed4 bottomCol = GetNeighborColor(i, 0, -1);
                fixed4 leftCol = GetNeighborColor(i, -1, 0);
                fixed4 rightCol = GetNeighborColor(i, 1, 0);
                fixed4 topRightCol = GetNeighborColor(i, 1, 1);
                fixed4 bottomRightCol = GetNeighborColor(i, 1, -1);
                fixed4 bottomLeftCol = GetNeighborColor(i, -1, -1);
                fixed4 topLeftCol = GetNeighborColor(i, -1, 1);

                // 卷积核：八方向-1，中间9
                col = col * 9 - topCol - bottomCol - leftCol - rightCol - topRightCol - bottomRightCol - bottomLeftCol - topLeftCol;
                
                return col;
            }
            
            ENDCG
        }
    }
}
