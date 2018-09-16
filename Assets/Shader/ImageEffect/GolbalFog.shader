Shader "ShaderLab_Study/GolbalFog" {
	Properties {
			_MainTex ("Base (RGB)", 2D) = "white" {}
			_FogStart("Fog Start",Float) = 1.0
			_FogEnd("Fog End",Float) = 1.0
			_FogDensity("Fog Density",Float) = 1.0
			_FogColor("Fog Color",Color) = (1.0,1.0,1.0,1.0)
			}
	SubShader {

		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		uniform sampler2D _CameraDepthTexture;
		uniform float4x4 _SceenVertexRayMat;
		float _FogStart;
		float _FogEnd;
		float _FogDensity;
		float4 _FogColor;

		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0; 
			float4 ray:TEXCOORD1;
		}; 

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;

			int index = 0;
			//左下角
			if(v.vertex.x < 0.5f && v.vertex.y < 0.5f)
			{
				index = 0;
			}
			//右下角
			else if(v.vertex.x > 0.5f && v.vertex.y < 0.5f)
			{
				index = 1;
			}
			//右上角
			else if(v.vertex.x > 0.5f && v.vertex.y > 0.5f)
			{
				index = 2;
			}
			//左上角
			else
			{
				index = 3;
			}

			o.ray = _SceenVertexRayMat[index];

			return o;
		}

		fixed4 frag(v2f i):SV_Target
		{
			//射线信息会进行插值处理
			//获取像素对应的深度信息(摄像机空间下)
			float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv));

			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.ray.xyz;

			float fogDensity  = (_FogEnd + worldPos.z)/(_FogEnd - _FogStart);
			fogDensity = saturate(fogDensity * _FogDensity);

			fixed4 color = tex2D(_MainTex,i.uv);
			color.rgb = lerp(color.rgb,_FogColor.rgb,fogDensity);

			return color;			
				
		}



		ENDCG
		ZTest Always
		Cull Off
		ZWrite Off
		Pass {

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
		
			ENDCG
		}
	}
	FallBack "Diffuse"
}
