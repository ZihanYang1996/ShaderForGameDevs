Shader "Practice/Lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", float) = 0.5
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
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.normal = v.normal;  // Object space normal
                o.normal = UnityObjectToWorldNormal(v.normal);  // World space normal
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz; // World space position
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Diffuse lighting
                float3 N = normalize(i.normal);  // Normalize interpolated normal so it's unit length
                float3 L = _WorldSpaceLightPos0.xyz;  // Point to the directional light
                // Lambertian reflection
                // max(0.0, dot(N,L)) is the same
                // float diffuseLight = saturate(dot(N,L));  
                float3 diffuseLight = saturate(dot(N,L)) * _LightColor0.rgb;

                // Specular lighting
                // Get view vector
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);  // Point to the camera from the fragment
                float3 R = reflect(-L, N);  // Reflect the light vector around the normal
                float3 specularLight = saturate(dot(V, R));
                specularLight = pow(specularLight, _Gloss);  // Glossiness, specular exponent

                return float4(specularLight.xxx, 1);
                return float4(diffuseLight, 1.0);
            }
            ENDCG
        }
    }
}