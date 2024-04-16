Shader "Practice/DiffuseLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.normal = v.normal;  // Object space normal
                o.normal = UnityObjectToWorldNormal(v.normal);  // World space normal
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 N = i.normal;
                float3 L = _WorldSpaceLightPos0.xyz;  // Point to the directional light
                
                // Lambertian reflection
                // max(0.0, dot(N,L)) is the same
                // float diffuseLight = saturate(dot(N,L));  
                float3 diffuseLight = saturate(dot(N,L)) * _LightColor0.rgb;
                return float4(diffuseLight, 1.0);
            }
            ENDCG
        }
    }
}
