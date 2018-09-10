Shader "ShaderLab_Study/BSCEffect" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
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
			half _Brightness;
			half _Saturation;
			half _Contrast;

			
			fixed4 frag(v2f_img i) : COLOR
			{

				//从_MainTex中根据uv坐标进行采样
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				//brigtness亮度直接乘以一个系数，也就是RGB整体缩放，调整亮度
				fixed3 finalColor = renderTex * _Brightness;
				//saturation饱和度：首先根据公式计算同等亮度情况下饱和度最低的值：
				fixed gray = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 grayColor = fixed3(gray, gray, gray);//灰度图
				//根据Saturation在饱和度最低的图像和原图之间差值
				finalColor = lerp(grayColor, finalColor, _Saturation);
				//contrast对比度：首先计算对比度最低的值
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				//根据Contrast在对比度最低的图像和原图之间差值
				finalColor = lerp(avgColor, finalColor, _Contrast);
				//返回结果，alpha通道不变

				
				return fixed4(finalColor,1);
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
