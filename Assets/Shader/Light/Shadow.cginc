
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
};


v2f vert(a2v v) {
	v2f i;
	i.vertex = UnityObjectToClipPos(v.vertex);
	i.worldPos = mul(unity_ObjectToWorld, v.vertex);
	i.normal = UnityObjectToWorldNormal(v.normal);
	i.uv = TRANSFORM_TEX(v.uv, _MainTex);
	//ComputeVertexLightColor(i);
	return i;
}

float4 frag(v2f i) : SV_TARGET{
	i.normal = normalize(i.normal);

	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	return UNITY_BRDF_PBS(
		albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		CreateLight(i), CreateIndirectLight(i)
	);
}