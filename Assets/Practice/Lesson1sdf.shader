Shader "Practice/Lesson1sdf"
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
            // src * x + det * y, src means the ouput of this shader, dest means the healthbarColoror of the pixel in the buffer
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

                float3 healthbarColor = tex2D(_MainTex, float2(_Health, i.uv.y));
                float healthbarMask = _Health > i.uv.x;

                
                
                if (_Health < 0.2)  // careful, if statement in shader can be expensive
                {
                    float flash = cos(_Time.y * 5) * 0.5 + 1;  // flash effect from 0.5 to 1.5
                    healthbarColor *= flash.xxx;
                }
                

                return float4(healthbarColor * healthbarMask, healthbarMask);
            }
            ENDCG
        }
    }
}
