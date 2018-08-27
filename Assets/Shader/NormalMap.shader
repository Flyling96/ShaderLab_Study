Shader "ShaderLab_Study/NormalMap"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20

	}
	SubShader
	{
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
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				float3x3 TBN = float3x3(i.worldTangent, i.worldBinormal, i.worldNormal);

				float3 normal = UnpackNormal(tex2D(_NormalMap, i.normalUV));
				normal.xy *= _BumpScale;

				normal = normalize(mul(normal,TBN));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normal, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
}
