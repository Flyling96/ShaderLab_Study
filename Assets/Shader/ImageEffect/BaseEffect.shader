Shader "ShaderLab_Study/BaseEffect" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;

			
			fixed4 frag(v2f_img i) : COLOR
			{
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				return renderTex;
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
