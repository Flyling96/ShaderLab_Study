Shader "Unlit/GpuParticle"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Blend SrcAlpha one

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma target 5.0

            #include "UnityCG.cginc"

			struct Particle
			{
				float3 position;
				float3 velocity;
			};

            struct v2f
            {
				float4 color : COLOR;
                float4 vertex : SV_POSITION;
            };

			StructuredBuffer<Particle> particleBuffer;

            v2f vert (uint vertex_id : SV_VertexID, uint instance_id : SV_InstanceID)
            {
                v2f o;
				//float speed = length(particleBuffer[instance_id].velocity);
				//float lerpValue = clamp(speed / _HighSpeedValue, 0.0f, 1.0f);
				//o.color = lerp(_ColorLow, _ColorHigh, lerpValue);
				o.color = float4(particleBuffer[instance_id].velocity, 1);
				// Position
				o.vertex = UnityObjectToClipPos(float4(particleBuffer[instance_id].position, 1.0f));
                return o;
            }

			float4 frag (v2f i) : SV_Target
            {
                return 1;
            }
            ENDCG
        }
    }
		Fallback Off
}
