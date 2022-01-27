// reference - https://www.shadertoy.com/view/ftsXD4
Shader "Unlit/Flag"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Bend("Bend", float) = 0
        _WaveSpeed("Wave Speed", float) = 0
        _WaveDir("Wave Dir", float) = 0
        _Curls("Curls", float) = 0
        _Shadow("Shadow", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define WHITE float4(255,255,255,255) / 255
            #define ORANGE float4(255,153,51,255) / 255
            #define GREEN float4(19,136,8,255) / 255
            #define BLUE float4(0,0,128,255) / 255

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
            float4 _MainTex_ST;
            float _Bend;
            float _WaveSpeed;
            float _WaveDir;
            float _Curls;
            float _Shadow;

            float2x2 rotate(float angle)
            {
                return float2x2(cos(angle), -sin(angle),  sin(angle), cos(angle));
            }

            float circle(float2 uv, float thickness, float size)
            {
                uv = uv - 0.5;
                uv.x *= _ScreenParams.x / _ScreenParams.y;
                float distance = size - length(uv) ;
                float color = smoothstep(0, 0.0005, distance);
                color *= smoothstep(thickness + 0.0005, thickness, distance);
                return color;
            }

            float circle(float2 uv, float radius)
            {
                float d = length(uv);
                return smoothstep(d - 0.003, d, radius);
            }

            float box(float2 uv, float2 size)
            {
                size = 0.5 - size * 0.5;
                float2 st = smoothstep(size, size, uv);
                st *= smoothstep(size, size, 1.0 - uv);
                return st.x * st.y;
            }

            float4 chakra(float2 uv, float radius)
            {
                float t = 6.2832 / 24;
                float c1 = circle(uv, radius + 0.02);
                float c2 = circle(uv, radius);
                float c3 = circle(uv, radius * 0.3);
                c2 -= c3;

                float cr = 0.125;
                float ca = 0;
                float offset = 0.12;
                for (int i = 0; i < 24; i++)
                {
                    float c = circle(float2(uv.x + sin(ca + offset) * cr, uv.y + cos(ca + offset) * cr), radius * 0.05);

                    float alfa = ((1.0 / 24) * (i - (24 * 0.25)) * 6.2832);
                    float shift = 0.04;
                    float a = alfa + shift;
                    float b = alfa - shift;
                    float2 p = float2(sin(ca), cos(ca)) * (radius * 0.5);
                    float d1 = dot(uv - p, float2(sin(a), cos(a)));
                    float d2 = dot(uv - p, -float2(sin(b), cos(b)));
                    float d3 = dot(uv - p, -float2(sin(a), cos(a)));
                    float d4 = dot(uv - p, float2(sin(b), cos(b)));

                    float d = max(max(d1, d2), max(d3, d4)) - 0.002;

                    c2 -= smoothstep(0.003, 0.0, d);
                    c2 -= min(c2, c);
                    ca += t;
                }

                return (c1 - c2) * BLUE;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float aspect = _ScreenParams.x / _ScreenParams.y;
                float2 uv = i.uv;

                float t = uv.x * _Curls - _WaveSpeed * _Time.y + uv.y * _WaveDir;
                uv.y += sin(t) * _Bend;

                float4 b1 = box(uv - float2(0, 0 + 0.33), float2(3, 0.33)) * ORANGE;
                float4 b2 = box(uv, float2(3, 0.33)) * WHITE;
                float4 b3 = box(uv - float2(0, -0.33), float2(3, 0.33)) * GREEN;

                uv.x *= aspect;
                uv -= float2(aspect / 2, 0.5);
                float4 c = chakra(uv, 0.125);
                float4 col = b1 + b2 + b3;
                col = lerp(col, c, c.a);

                col *= 0.7 + cos(t) * _Shadow;

                return col;
            }
            ENDCG
        }
    }
}