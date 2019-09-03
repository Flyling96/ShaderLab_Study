#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"


float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _ShadowDepthTex;
float4x4 _ShadowCameraView;
float4x4 _ShadowCameraProj;

float _Metallic;
float _Smoothness;


struct a2v
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD0;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
	//float3 shadowProjPos:TEXCOORD3;
};

UnityIndirect CreateIndirectLight(v2f i) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

#if defined(VERTEXLIGHT_ON)
	indirectLight.diffuse = i.vertexLightColor;
#endif

#if defined(FORWARD_BASE_PASS)
	indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
#endif

	return indirectLight;
}

UnityLight CreateLight(v2f i) {
	UnityLight light;

#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
	light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#else
	light.dir = _WorldSpaceLightPos0.xyz;
#endif

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

v2f vert(a2v v) {
	v2f i;
	i.vertex = UnityObjectToClipPos(v.vertex);
	i.worldPos = mul(unity_ObjectToWorld, v.vertex);
	i.normal = UnityObjectToWorldNormal(v.normal);
	i.uv = TRANSFORM_TEX(v.uv, _MainTex);


	//ComputeVertexLightColor(i);
	return i;
}

half DecodeDepth(half2 depth)
{
	half2 decodeMul = half2(1.0, 1/255.0);
	return dot(depth, decodeMul);
}

float4 frag(v2f i) : SV_TARGET{
	//return float4(i.shadowProjPos,1);

	i.normal = normalize(i.normal);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	//shadow

	float4 shadowProjPos = mul(_ShadowCameraProj, mul(_ShadowCameraView, float4(i.worldPos,1)));
	shadowProjPos /= shadowProjPos.w;
	shadowProjPos = shadowProjPos *0.5f + 0.5f;
	//return float4(shadowProjPos.xyz, 1);
	
	//return 1 - shadowProjPos.z;
	half shadowDepth = DecodeDepth(tex2D(_ShadowDepthTex, shadowProjPos.xy).xy);
	//return shadowDepth ;

	//half shadowDepth = tex2D(_ShadowDepthTex, shadowProjPos.xy).x;
	//return shadowDepth;

	half shadow =  step(shadowDepth,1 - shadowProjPos.z + 0.001);
	//return shadow;

	return UNITY_BRDF_PBS(
		albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		CreateLight(i), CreateIndirectLight(i)
	) * shadow;
}