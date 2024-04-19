Shader "Practice/Lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Range(0, 1)) = 0.5
        _Color ("Color", Color) = (1, 1, 1, 1)
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
            float4 _Color;

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
                float lambert = saturate(dot(N,L));  
                float3 diffuseLight = lambert * _LightColor0.rgb;
                // return float4(diffuseLight, 1.0);

                // Specular Exponent
                float specularExponent = exp2(_Gloss * 6) + 2;  // For optimization, put it in C# scripta


                // // Specular lighting, Phong
                // // Get view vector
                // float3 V = normalize(_WorldSpaceCameraPos - i.wPos);  // Point to the camera from the fragment
                // float3 R = reflect(-L, N);  // Reflect the light vector around the normal
                // float3 specularLight = saturate(dot(V, R));
                // specularLight = pow(specularLight, specularExponent);  // Glossiness, specular exponent


                // Specular lighting, Blinn-Phong
                // Get view vector
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);  // Point to the camera from the fragment
                float3 H = normalize(L + V);  // Half vector
                // float3 specularLight = saturate(dot(H, N));
                float3 specularLight = saturate(dot(N, H)) * (lambert > 0);  // Remove the 'spotlight' effect when the light is behind the object
                specularLight = pow(specularLight, specularExponent);  // Glossiness, specular exponent

                specularLight = specularLight * _LightColor0.rgb;  // Apply light color

                return float4(specularLight + diffuseLight * _Color, 1);
                
            }
            ENDCG
        }
    }
}
