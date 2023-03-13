Shader "Master/SpriteShader/SpritesDefault"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		
		// 刷新速度
		_Speed ("Speed", float) = 1
		// 函数跨度？经测试随数值增大，效果先变大再变小
		_Span ("Span", float) = 1
		// 偏移程度？数值越大，偏移后的像素可以离原来位置越远
		_LerpFactor("LerpFactor", Range(0,0.1)) = 0.002
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"
		
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
			};
		
			fixed4 _Color;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;

			float _Speed;
			float _Span;
			float _LerpFactor;

			fixed4 SampleSpriteTexture (float2 uv)
			{
				float speed = floor(_Time.z * _Speed);	// _Time是个不断增大的数，取整数值，限制刷新次数

				// 用余弦和正弦函数 对uv上的像素进行位置偏移
				float2 originalUV = uv;
				uv.x = sin((uv.x * 10  + speed) * _Span);
				uv.y = cos((uv.y * 10  + speed) * _Span);
				// 原位置和新位置做一个插值，限制偏移范围
				uv.xy = lerp(originalUV,originalUV + uv, _LerpFactor);
				
				fixed4 color = tex2D (_MainTex, uv);

#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
				if (_AlphaSplitEnabled)
					color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

				return color;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
}