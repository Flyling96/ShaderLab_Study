﻿Shader "ShaderLab_Study/BaseEffect" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		ZTest Always
		Cull Off
		ZWrite Off
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;

			
			fixed4 frag(v2f_img i) : COLOR
			{
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				renderTex.a = 1;
				return renderTex;
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
