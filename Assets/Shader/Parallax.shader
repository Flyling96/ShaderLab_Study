Shader "Unlit/Parallax"
{
    Properties
    {
		_Color("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Albedo", 2D) = "white" {}

		[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1

		[NoScaleOffset] _ParallaxMap("Parallax", 2D) = "black" {}
		_ParallaxStrength("Parallax Strength", Range(0, 0.5)) = 0

		_DetailTex("Detail Albedo", 2D) = "gray" {}

		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags{ "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 tangentViewDir:TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				float3 worldTangent : TEXCOORD4;
				float3 worldBinormal : TEXCOORD5;
            };

			float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _NormalMap;
			float _BumpScale;
			sampler2D _ParallaxMap;
			sampler2D _DetailTex;
			float4 _DetailTex_ST;
			float _ParallaxStrength;
			fixed4 _Specular;
			float _Gloss;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
				float3x3 WorldTBN = float3x3
				(
					o.worldTangent,
					o.worldBinormal,
					o.worldNormal
				);

				o.tangentViewDir = mul(WorldTBN, WorldSpaceViewDir(v.vertex));

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

			//简单地以高度为权重进行UV偏移的计算
			//具有偏移限制
			float2 ParallaxOffset(float2 uv, float2 viewDir) 
			{
				float height = tex2D(_ParallaxMap, uv).g;
				height = height * 2 - 1;
				height *= _ParallaxStrength;
				float2 uvOffset = viewDir * height;
				return uvOffset;
			}

			//raymarching
			//在高度场中步进
			float2 ParallaxRaymarching(float2 uv, float2 viewDir) 
			{
				float2 uvOffset = 0;
				float stepSize = 0.05;
				float2 uvDelta = viewDir * stepSize * _ParallaxStrength;
				float stepHeight = 1;
				float height = tex2D(_ParallaxMap, uv).g;

				for (int i = 0; i < 10 && stepHeight > height; i++) {

					uvOffset -= uvDelta;
					stepHeight -= stepSize;
					height = tex2D(_ParallaxMap, uv + uvOffset).g;

				}

				//二分法逼近正确的交点
				for (int i = 0; i < 10; i++) {

					uvDelta *= 0.5;
					stepSize *= 0.5;

					if (stepHeight < height) {
						uvOffset += uvDelta;
						stepHeight += stepSize;
					}
					else {
						uvOffset -= uvDelta;
						stepHeight -= stepSize;
					}
					height = tex2D(_ParallaxMap, uv + uvOffset).g;
				}

				return uvOffset;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				//return float4(i.tangentViewDir.xyz,1);

				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//视差处理
				i.tangentViewDir = normalize(i.tangentViewDir);
				i.tangentViewDir.xy /= i.tangentViewDir.z + 0.42f;
				float2 uvOffset = ParallaxRaymarching(i.uv.xy, i.tangentViewDir);
				i.uv.xy += uvOffset;
				i.uv.zw += uvOffset * (_DetailTex_ST.xy / _MainTex_ST.xy);


				float3x3 WorldTBN = float3x3
				(
					i.worldTangent,
					i.worldBinormal,
					i.worldNormal
				);


				float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv.xy));
				normal.xy *= _BumpScale;
				normal = normalize(mul(normal, WorldTBN));
                
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb * tex2D(_DetailTex, i.uv.zw).rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo * 5;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normal, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
