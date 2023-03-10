Shader "Master/SpriteShader/BlackHole"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		
		// 旋转速度
		_Speed("Speed", float) = 0.5
		// 旋转中心
		_CenterX("CenterX", Range(0, 1)) = 0.5
		_CenterY("CenterY", Range(0, 1)) = 0.5
		// 漩涡半径
		_Radius("Radius", float) = 0.5
		// 内圈压黑半径
		_InnerRadius("InnerRadius", float) = 0.1
		// 外圈虚化半径
		_OuterRadius("OuterRadius", float) = 0.6
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

			float _Speed;
			float _CenterX;
			float _CenterY;
			float _Radius;

			float4 Vortex(sampler2D tex, float2 uv)
			{
				float2 center = float2(_CenterX, _CenterY);

				float2 xyFromCenter = uv.xy - center;
				float curRadius = length(xyFromCenter);

				if(curRadius < _Radius)
				{
					// 当前半径在漩涡半径中的比例
					float percent = (_Radius - curRadius) / _Radius;
					// 计算弧度（与比例成反比，越靠近漩涡中心旋转越厉害）
					float theta = percent * percent * 16;

					float sinX = sin(theta);
					float cosX = cos(theta);
					float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
					xyFromCenter = mul(xyFromCenter, rotationMatrix);
				}
				xyFromCenter += center;
				
				fixed4 color = tex2D (tex, xyFromCenter);
				return color;
			}
		

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;

			float _InnerRadius;
			float _OuterRadius;
		
			fixed4 SampleSpriteTexture (float2 uv)
			{
				// speed*time得到旋转弧度
				float sinX = sin(_Speed * _Time);
				float cosX = cos(_Speed * _Time);
				// 旋转矩阵
				float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);

				float2 center = float2(_CenterX, _CenterY);

				// 单纯的旋转
				// 如果没有加减center的操作，会绕左下角原点旋转
				uv -= center;
				uv.xy = mul(uv, rotationMatrix);
				uv += center;

				// 漩涡处理
				fixed4 color = Vortex(_MainTex, uv);

				// 边缘处理
				float innerEdge = smoothstep(0, _InnerRadius, length(uv.xy - float2(0.5, 0.5)));
				// 内圈调暗颜色
				color.rgb *= innerEdge;
				float outerEdge = 1.0 - smoothstep(_InnerRadius + 0.1, _OuterRadius, length(uv.xy - float2(0.5, 0.5)));
				// 外圈降低透明度
				color.a *= outerEdge;
				

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