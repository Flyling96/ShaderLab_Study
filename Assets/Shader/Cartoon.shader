Shader "ShaderLab_Study/Cartoon"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_Outline ("Outline", Range(0, 1)) = 0.01
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_FirstShadowThreshold ("First Shadow Threshold",Range(0,1)) = 0.5
		_FirstShadowColor("First Shadow Color",Color) = (0.25,0.25,0.25,0.25)
		_SecondShadowThreshold ("First Shadow Threshold",Range(0,1)) = 0.25
		_SecondShadowColor("First Shadow Color",Color) = (0.1,0.1,0.1,0.1)


	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}

		Pass {
			NAME "OUTLINE"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float _Outline;
			fixed4 _OutlineColor;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
				normal.z = -0.5;
				o.normal = normal;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);
				
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				return float4(i.normal,1);
				return float4(_OutlineColor.rgb, 1);               
			}
			
			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float2 normalUV : TEXCOORD3;
				float3 worldTangent : TEXCOORD4;
				float3 worldBinormal : TEXCOORD5;
			};

			float3 _Color; 
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			fixed4 _Specular;
			float _Gloss;
			float _BumpScale;
			float _FirstShadowThreshold;
			float4 _FirstShadowColor;
			float _SecondShadowThreshold;
			float4 _SecondShadowColor;
			float _SpecularScale;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normalUV = TRANSFORM_TEX(v.uv, _NormalMap);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);// UnityObjectToWorldNormal(v.normal);
				o.worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz); //UnityObjectToWorldDir(v.tangent.xyz);
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 1;
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				float3x3 TBN = float3x3(i.worldTangent, i.worldBinormal, i.worldNormal);

				float3 normal = UnpackNormal(tex2D(_NormalMap, i.normalUV));
				normal.xy *= _BumpScale;

				normal = normalize(mul(normal,TBN));
				//return float4(normal, 1);

				fixed diff =  dot(normal, lightDir);
				fixed4 shadowColor;
				if(diff<_FirstShadowThreshold && diff>_SecondShadowThreshold)
				{
					shadowColor = _FirstShadowColor;
				}
				else if(diff<_SecondShadowThreshold)
				{
					shadowColor = _SecondShadowColor;
				}
				else 
				{
					shadowColor = fixed4(1, 1, 1, 1);
				}


				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * shadowColor.rgb;

				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed spec = dot(normal, halfDir);
				fixed w = fwidth(spec) * 2.0;
				
				fixed3 specular = _LightColor0.rgb *_Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
}
