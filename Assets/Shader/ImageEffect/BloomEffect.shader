Shader "ShaderLab_Study/BloomEffect" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bloom ("Bloom (RGB)", 2D) = "black" {}
		_BrightThreshold ("Bright Threshold", Float) = 0.5
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {

		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _Bloom;
		float _BlurSize;
		float _BrightThreshold;

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0; 
		}; 

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;

			return o;
		}

		fixed luminance(fixed4 color) 
		{
			return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
		}

		fixed4 fragExtractBright(v2f i):SV_Target
		{
			fixed4 c = tex2D(_MainTex,i.uv);
			fixed val = clamp(luminance(c) - _BrightThreshold, 0.0,1.0);
			return c * val;
		}


		fixed4 flagBloom(v2f i):SV_Target
		{
			return tex2D(_MainTex, i.uv) + tex2D(_Bloom, i.uv);
		}




		ENDCG
		
		ZTest Always Cull Off ZWrite Off
		Pass {

			NAME "BLOOM_EXTRACT_BRIGHT"

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment fragExtractBright
		
			ENDCG
		}

		UsePass "ShaderLab_Study/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"

		UsePass "ShaderLab_Study/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

		Pass {

			NAME "BLOOM_BLEND_BRIGHT"

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment flagBloom
		
			ENDCG
		}		
	}
	FallBack Off
}
