Shader "Unlit/ShadowDepth"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 worldPos: TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4x4 _ShadowCameraView;
			float4x4 _ShadowCameraProj;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			half2 EncodeDepth(half depth)
			{
				half2 encodeMul = half2(1.0f,255.0f);
				half encodeBit = 1.0f / 255.0f;
				half2 res = encodeMul * depth;
				res = frac(res);
				res.x -= res.y * encodeBit;
				return res;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 shadowProjPos = mul(_ShadowCameraProj,mul(_ShadowCameraView,i.worldPos));
				shadowProjPos /= shadowProjPos.w;
				shadowProjPos = shadowProjPos * 0.5f + 0.5f;

				//shadowProjPos / = shadowProjPos.w;
				half2 res = EncodeDepth(i.vertex.z);
				return float4(res.x, res.y,0,1);
			}
			ENDCG
		}
	}
}
