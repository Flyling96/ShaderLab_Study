Shader "Unlit/Parallax"
{
    Properties
    {
		_Color("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Albedo", 2D) = "white" {}

		[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1

		[NoScaleOffset] _ParallaxMap("Parallax", 2D) = "black" {}
		_ParallaxStrength("Parallax Strength", Range(0, 0.1)) = 0

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
				float2 uv : TEXCOORD0;
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
			float _ParallaxStrength;
			fixed4 _Specular;
			float _Gloss;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldNormal = UnityObjectToWorldDir(v.normal);
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

            fixed4 frag (v2f i) : SV_Target
            {
				//return float4(i.tangentViewDir.xyz,1);

				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//视差处理
				//具有偏移限制
				i.tangentViewDir = normalize(i.tangentViewDir);
				i.tangentViewDir.xy /= (i.tangentViewDir.z + 0.42);
				float height = tex2D(_ParallaxMap, i.uv.xy).g;
				height = height * 2 - 1;
				height *= _ParallaxStrength;
				i.uv.xy += i.tangentViewDir.xy * height;




				float3x3 WorldTBN = float3x3
				(
					i.worldTangent,
					i.worldBinormal,
					i.worldTangent
				);


				float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
				normal.xy *= _BumpScale;
				normal = normalize(mul(normal, WorldTBN));
                
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo * 3;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normal, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
