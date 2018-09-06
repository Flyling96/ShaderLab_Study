Shader "ShaderLab_Study/Glass"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Cubemap("Reflection Cubemap",Cube) = "_Skybox" {}
		_Distortion ("Distortion", Range(0, 100)) = 10
		_RefractAmount ("Refract Amount", Range(0.0,1.0)) = 1.0
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_LightRange("LightRange",Range(0.0,1.0)) = 0.3
		_Noise("Noise", 2D) = "white" {}
		_ChangeSpeed("ChangeSpeed",Range(0,5)) = 0.5
		_ChangePower("ChagePower",Range(-1.0,1.0)) = 0

		

	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Opaque" }
		
		GrabPass {"_RefractionTex"}

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
				float4 scrPos : TEXCOORD6; //屏幕图像的采样坐标
			};

			float3 _Color; 
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			fixed4 _Specular;
			float _Gloss;
			float _BumpScale;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			float _LightRange;
			sampler2D _Noise;
			float _ChangeSpeed;
			float _ChangePower;
			
			v2f vert (a2v v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normalUV = TRANSFORM_TEX(v.uv, _NormalMap);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;

				o.scrPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				float3x3 TBN = float3x3(i.worldTangent, i.worldBinormal, i.worldNormal);

				float3 normal = UnpackNormal(tex2D(_NormalMap, i.normalUV));
				normal.xy *= _BumpScale;


				//在切线空间下进行偏移量的计算
				float2 offset = normal.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;

				//用噪声进行偏移
				float2 noiseUV = i.uv + _SinTime *_ChangeSpeed;
				fixed3 noiseColor = tex2D(_Noise, noiseUV).rgb;
				i.scrPos.xy += noiseColor.xy*_ChangePower;

				//需要将屏幕图像的采样坐标转换为齐次坐标
				fixed3 refractColor = tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;

				normal = normalize(mul(normal,TBN));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				

				//计算光源入射方向
				fixed3 reflDir = reflect(-viewDir, normal);
				fixed3 reflectColor = texCUBE(_Cubemap, reflDir).rgb * albedo;

				//通过反射和折射的比例计算颜色
				fixed3 finalColor = reflectColor * (1 - _RefractAmount) + refractColor * _RefractAmount;


				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;

				fixed3 diffuse = _LightColor0.rgb  * max(0, dot(normal, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);

				return fixed4((ambient + diffuse + specular) * _LightRange+ finalColor, 1.0);
			}
			ENDCG
		}
	}
}
