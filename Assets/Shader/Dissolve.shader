Shader "ShaderLab_Study/Dissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseMap("Burn Map",2D) = "white"{}
		_BurnLineWidth("Burn Line Width",Range(0.0,0.2)) = 0.1
		_BurnFirstColor("Burn First Color",Color) = (1,1,1,1)
		_BurnSecondColor("Burn Second Color",Color) = (1,1,1,1)
		_BurnAmount("Burn Amount",Range(0.0,1.0)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase"}
			Cull off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#pragma multi_compile_fwdbase

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uvNoiseMap : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseMap;
			float4 _NoiseMap_ST;
			float _BurnLineWidth;
			float4 _BurnFirstColor;
			float4 _BurnSecondColor;
			float _BurnAmount;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseMap = TRANSFORM_TEX(v.uv,_NoiseMap);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed4 noiseColor = tex2D(_NoiseMap,i.uvNoiseMap);
				clip(noiseColor.r - _BurnAmount);
				fixed4 diffuse = _LightColor0 * texColor + UNITY_LIGHTMODEL_AMBIENT* texColor;

				fixed burnLineAmount = 1 - smoothstep(0.0,_BurnLineWidth,noiseColor.r - _BurnAmount);
				fixed4 burnColor = lerp(_BurnFirstColor,_BurnSecondColor, burnLineAmount);

				fixed4 finalColor = lerp(diffuse, burnColor, burnLineAmount * step(0.00001, _BurnAmount));
				return finalColor;
			}
			ENDCG
		}
	}
}
