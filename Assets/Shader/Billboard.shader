Shader "ShaderLab_Study/Billboard"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

		Pass
		{
			Tags{ "LightMode"="ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha
			Cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			
			v2f vert (a2v v)
			{
				v2f o;
				float3 center = float3(0,0,0);
				//模型空间下的摄像机位置
				float3 viewPos = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
				//将视角方向作为法线方向（为了让广告牌的正面一直朝着摄像机）
				float3 normalDir =normalize(viewPos - center);

				//求出三个正交基
				//防止法线方向和上方向平行
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));

				//模型空间下的新顶点位置计算
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.pos = UnityObjectToClipPos(float4(localPos,1));
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _Color.rgb;
				return col;
			}
			ENDCG
		}
	}
}
