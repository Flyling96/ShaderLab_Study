Shader "Unlit/TexPreview"
{
    Properties
    {
        //_Source("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _Source;
            float4 _Source_ST;
            int _Encode;

            sampler2D _Mask;
            float4 _Mask_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Source);
                return o;
            }

            fixed4 encode(float2 uv)
            {
                fixed4 source = tex2D(_Source, uv);
                fixed4 mask = tex2D(_Mask, uv);

                fixed4 res;
                fixed b = source.b * 0.3333f;
                res.r = source.r * (1 - b);
                res.g = source.g * (1 - b);
                res.b = mask.r;
                res.a = source.a;

                return res;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_Source, i.uv) * step(_Encode,0) + encode(i.uv) *( 1 - step(_Encode,0));
                return col;
            }

            ENDCG
        }
    }
}
