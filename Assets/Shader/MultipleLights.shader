Shader "ShaderLab_Study/MultipleLights"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_MainTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//保证使用光照衰减等光照变量可以被正常赋值
			#pragma multi_compile_fwdbase

			//平行光
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Diffuse.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(dot(worldNormal, worldLightDir), 0);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4((ambient + diffuse + specular)*atten,1);

			}
			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardAdd" }

			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//保证使用光照衰减等光照变量可以被正常赋值
			//#pragma multi_compile_fwdadd
			//阴影
			#pragma multi_compile_fwdadd_fullshadows
				
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;


			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
#ifdef USING_DIRECTIONAL_LIGHT
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
#endif	

				fixed4 texColor = tex2D(_MainTex, i.uv);

				fixed3 albedo = texColor.rgb * _Diffuse.rgb;
	
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(dot(worldNormal, worldLightDir), 0);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
//#ifdef USING_DIRECTIONAL_LIGHT
//				fixed atten = 1.0;//衰减参数
//#else
//#if defined (POINT)
//				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
//				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
//#elif defined (SPOT)
//				float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
//				fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
//#else
//				fixed atten = 1.0;
//#endif
//#endif
				return fixed4((ambient + diffuse + specular) * atten  ,1);

			}
				ENDCG
		}
	}
	FallBack "Specular"
}
