Shader "ShaderLab_Study/EdgeDetection" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Float) = 1.0
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass {
			ZTest Always
			Cull Off
			ZWrite Off
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			float _EdgeOnly;
			float4 _EdgeColor;
			float4 _BackgroundColor;

			struct v2f
			{
				float4 pos:SV_POSITION;
				half2 neightor[9]:TEXCOORD0; 
			};

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				half2 uv = v.texcoord;

				o.neightor[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
				o.neightor[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
				o.neightor[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
				o.neightor[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
				o.neightor[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
				o.neightor[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
				o.neightor[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
				o.neightor[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
				o.neightor[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
						 
				return o;

			}
			
			fixed luminance(fixed4 color) {
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
			}
			

			half Sobel(v2f i)
			{
				half Gx[9] = {-1,  0,  1,
							  -2,  0,  2,
							  -1,  0,  1};
				half Gy[9] = {-1, -2, -1,
							   0,  0,  0,
							   1,  2,  1};	

				half texColor;
				half edgeX = 0;
				half edgeY = 0;
				for(int j=0;j<9;j++)
				{
					//取灰度值
					texColor = luminance(tex2D(_MainTex,i.neightor[j]));
					edgeX += texColor * Gx[j];
					edgeY += texColor * Gy[j];
				}

				half edge = 1 - abs(edgeX) - abs(edgeY);
				
				return edge;

			}

			
			fixed4 frag(v2f i) : COLOR
			{
				half edge = Sobel(i);

				//i.neightor[4]为当前像素颜色
				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.neightor[4]), edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);

			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
