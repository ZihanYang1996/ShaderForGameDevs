Shader "Unlit/Lesson1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 1
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {

            ZWrite Off  // don't write to depth buffer
            // src * x + det * y, src means the ouput of this shader, dest means the color of the pixel in the buffer
            // AlphaBlending: src * src.a + dest * (1 - src.a)
            Blend SrcAlpha OneMinusSrcAlpha  // alpha blending

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float value)
            {
                // return a value between 0 and 1 based on the input value
                return saturate((value - a) / (b - a));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // return float4(1, 0, 0, i.uv.x);  // test alpha blending

                // calculate healthbar mask
                // float healthbarMask = 1 - step(_Health, i.uv.x);
                // float healthbarMask = i.uv.x > _Health ? 0 : 1;
                float healthbarMask = _Health > i.uv.x;
                // float healthbarMask = _Health > floor(i.uv.x * 8)/8;  // 8 segments

                // clip if healthbarMask is less than 0 to achieve transparency
                // clip(healthbarMask - 0.0001); // clip if healthbarMask is less than 0

                // calculate healthbar color
                float tHelathColor = InverseLerp(0.2, 0.8, _Health);
                float3 healthbarColor = lerp(float3(1, 0, 0), float3(0, 1, 0), tHelathColor);         

                // float3 bgColor = float3(0, 0, 0);

                // float3 finalColor = lerp(bgColor, healthbarColor, healthbarMask);
                
                // return float4(finalColor, 1);
                return float4(healthbarColor, healthbarMask);
            }
            ENDCG
        }
    }
}
