Shader "ShaderLab_Study/WaterWave"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_Cubemap("Reflection Cubemap",Cube) = "_Skybox" {}
		_Distortion ("Distortion", Range(0, 100)) = 10
		_RefractAmount ("Refract Amount", Range(0.0,1.0)) = 1.0
		_LightRange("LightRange",Range(0.0,1.0)) = 0.3
		_DVFactor("DVFactor", Range(0, 100)) = 60
		_MinDVFactor("MinDVFactor", Range(0, 100)) = 30
		_TimeFactor("TimeFactor", Range(0, 20)) = 10
		_WaterWaveFactor("WaterWaveFactor",Range(0.0, 1.0)) = 1.0
		_MinWaterWaveFactor("MinWaterWaveFactor",Range(0.0, 1.0)) = 0.5

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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float4 scrPos : TEXCOORD3; //屏幕图像的采样坐标
			};

			float3 _Color; 
			fixed4 _Specular;
			float _Gloss;
			float _BumpScale;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			float _LightRange;
			float _DVFactor;
			float _MinDVFactor;
			float _TimeFactor;
			float _WaterWaveFactor;
			float _MinWaterWaveFactor;

			
			v2f vert (a2v v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.scrPos = ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				i.scrPos.xy = i.scrPos.xy / i.scrPos.w;

				float2 dv = i.scrPos.xy - float2(0.5, 0.5);
				dv = dv * float2(_ScreenParams.x / _ScreenParams.y, 1);
				float dis = sqrt(dv.x * dv.x + dv.y * dv.y);

				_DVFactor = _DVFactor - _Time.y * 5;
				if (_DVFactor < _MinDVFactor)
				{
					_DVFactor = _MinDVFactor;
				}
				_WaterWaveFactor = _WaterWaveFactor - _Time.y * 0.1;
				if(_WaterWaveFactor<_MinWaterWaveFactor)
				{
					_WaterWaveFactor = _MinWaterWaveFactor;
				}



				float sinFactor = sin(dis * _DVFactor + _Time.y * _TimeFactor)* 0.01 *_WaterWaveFactor;

				float2 dv1 = normalize(dv);

				float2 offset = dv1  * sinFactor;


				fixed3 refractColor = tex2D(_RefractionTex,i.scrPos.xy + offset).rgb;

				

				//计算光源入射方向
				fixed3 reflDir = reflect(-viewDir, i.worldNormal);
				reflDir.xy += offset;
				fixed3 reflectColor = texCUBE(_Cubemap, reflDir).rgb;

				//通过反射和折射的比例计算颜色
				fixed3 finalColor = reflectColor * (1 - _RefractAmount) + refractColor * _RefractAmount;


				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;

				fixed3 diffuse = _LightColor0.rgb  * max(0, dot(i.worldNormal, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);

				return fixed4((ambient + diffuse + specular) * _LightRange+ finalColor, 1.0);
			}
			ENDCG
		}
	}
}
