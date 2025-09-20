Shader "Custom/Hyperwarp"
{
    Properties
    {
        _Speed ("Warp Speed", Range(0.1, 10.0)) = 2.0
        _BackgroundColor ("Background Color", Color) = (0.0, 0.0, 0.0, 1)
        
        // Light beam properties - ULTRA AGGRESSIVE QUEST 2 OPTIMIZATION (90+ FPS TARGET)
        _BeamCount ("Light Beam Count", Range(4, 8)) = 6
        _BeamBrightness ("Beam Brightness", Range(0.1, 2.5)) = 2.2
        _BeamColor1 ("Beam Color 1", Color) = (1.0, 1.0, 1.0, 1) // White
        _BeamColor2 ("Beam Color 2", Color) = (0.8, 0.9, 1.0, 1) // Blue-white
        _BeamThickness ("Beam Thickness", Range(0.012, 0.03)) = 0.02
        _BeamLength ("Beam Length", Range(0.6, 1.0)) = 0.8
        _CenterSize ("Center Hole Size", Range(0.08, 0.15)) = 0.1
        
        // Star properties - ULTRA AGGRESSIVE QUEST 2 OPTIMIZATION (90+ FPS TARGET)
        _StarCount ("Star Count", Range(4, 10)) = 6
        _StarBrightness ("Star Brightness", Range(0.1, 2.0)) = 1.5
        _StarColor ("Star Color", Color) = (1,1,1,1)
        _StarSpeed ("Star Speed", Range(0.4, 1.0)) = 0.7
        _StarSize ("Star Size", Range(0.012, 0.03)) = 0.02
    }
    
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        
        // Render back faces for inverted sphere
        Cull Front
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
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
            
            float _Speed;
            float4 _BackgroundColor;
            
            // Light beam variables
            float _BeamCount;
            float _BeamBrightness;
            float4 _BeamColor1;
            float4 _BeamColor2;
            float _BeamThickness;
            float _BeamLength;
            float _CenterSize;
            
            // Star variables
            float _StarCount;
            float _StarBrightness;
            float4 _StarColor;
            float _StarSpeed;
            float _StarSize;
            
            // ULTRA-FAST hash function for Quest 2
            float hash(float n)
            {
                return frac(sin(n) * 1234.56); // Faster calculation
            }
            
            // Ultra-simplified line distance for Quest 2
            float lineDistance(float2 p, float2 a, float2 b)
            {
                float2 ba = b - a;
                float t = saturate(dot(p - a, ba) / dot(ba, ba));
                return length(p - a - ba * t);
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Check if we're in the main VR player camera ONLY
                bool isMainVRCamera = false;
                
                #if UNITY_EDITOR
                // In editor, check multiple conditions to ensure it's the main camera
                // Scene view cameras have very different projection matrices
                if (unity_CameraProjection[1][1] > 0.5 && unity_CameraProjection[1][1] < 10.0)
                {
                    // Additional check: main camera usually has near plane around 0.1-1.0
                    if (unity_CameraProjection[2][3] < -0.05 && unity_CameraProjection[2][3] > -5.0)
                    {
                        // Check if this looks like a VR camera (stereo rendering)
                        // VR cameras often have specific projection characteristics
                        isMainVRCamera = true;
                    }
                }
                #else
                // In build, we can be more permissive since only game cameras will render
                // But still check for reasonable projection values
                if (unity_CameraProjection[1][1] > 0.1 && unity_CameraProjection[1][1] < 50.0)
                {
                    isMainVRCamera = true;
                }
                #endif
                
                // EXTRA SAFETY: Check camera position isn't at extreme values (editor cameras often are)
                float3 cameraWorldPos = float3(UNITY_MATRIX_V[0][3], UNITY_MATRIX_V[1][3], UNITY_MATRIX_V[2][3]);
                if (length(cameraWorldPos) > 1000.0) // If camera is very far away, probably not main camera
                {
                    isMainVRCamera = false;
                }
                
                // If not main VR camera, return transparent/background color
                if (!isMainVRCamera)
                {
                    return float4(_BackgroundColor.rgb, 0.0); // Make transparent for non-VR cameras
                }
                
                // === WARP TUNNEL EFFECTS (Only for main VR camera) ===
                
                // Convert UV to centered coordinates (-1 to 1)
                float2 uv = (i.uv - 0.5) * 2.0;
                
                float time = _Time.y * _Speed;
                float dist = length(uv);
                float angle = atan2(uv.y, uv.x);
                
                float4 color = _BackgroundColor;
                
                // === ULTRA AGGRESSIVE QUEST 2 LIGHT BEAMS - 90+ FPS TARGET ===
                float beamIntensity = 0.0;
                
                // Hard limit beams to 6 for maximum Quest 2 performance
                int maxBeams = min((int)_BeamCount, 6);
                
                [unroll(6)] // Ultra-small unroll for Quest 2
                for(int j = 0; j < maxBeams && j < 6; j++)
                {
                    float beamIndex = float(j);
                    
                    // Ultra-fast hash with more variation
                    float hash1 = frac(sin(beamIndex * 12.34 + time * 0.5) * 1234.56);
                    float hash2 = frac(sin(beamIndex * 56.78 + time * 0.3) * 1234.56);
                    float hash3 = frac(sin(beamIndex * 91.23 + time * 0.7) * 1234.56);
                    
                    // More randomized beam positioning
                    float beamAngle = hash1 * 6.28318 + time * 0.1;
                    float2 beamDir = float2(cos(beamAngle), sin(beamAngle));
                    
                    // Faster, more varied beam animation
                    float beamProgress = frac(hash2 + time * _Speed * 0.25);
                    float beamStart = _CenterSize + (hash3 * 0.3 + beamProgress * 0.2);
                    float beamEnd = beamStart + _BeamLength * (0.5 + hash3 * 0.4);
                    
                    // Create beam line
                    float2 beamStartPos = beamDir * beamStart;
                    float2 beamEndPos = beamDir * beamEnd;
                    
                    // Ultra-simplified distance calculation with slight randomness
                    float lineDist = lineDistance(uv, beamStartPos, beamEndPos);
                    
                    // Simple beam visibility with random thickness variation
                    float pointDist = length(uv);
                    float beamMask = step(beamStart, pointDist) * step(pointDist, beamEnd);
                    
                    // Ultra-simplified beam calculation with thickness variation
                    float thicknessVariation = 0.8 + hash3 * 0.4;
                    float beam = exp(-lineDist * 40.0 / (_BeamThickness * thicknessVariation)) * beamMask;
                    
                    // Minimal head glow
                    float headGlow = exp(-abs(pointDist - beamEnd) * 10.0) * 0.2;
                    beam += headGlow;
                    
                    beamIntensity += beam;
                }
                
                // Ultra-simple color variation for Quest 2
                float colorMix = sin(time * 0.2 + angle * 0.5) * 0.5 + 0.5;
                float4 beamColor = lerp(_BeamColor1, _BeamColor2, colorMix);
                color = lerp(color, beamColor, saturate(beamIntensity * _BeamBrightness));
                
                // === ULTRA AGGRESSIVE QUEST 2 STARS - 90+ FPS TARGET ===
                float starIntensity = 0.0;
                
                // Hard limit stars to 6 for maximum Quest 2 performance
                int maxStars = min((int)_StarCount, 6);
                
                [unroll(6)] // Ultra-small loop for Quest 2
                for(int k = 0; k < maxStars && k < 6; k++)
                {
                    float starIndex = float(k);
                    
                    // Faster, more random star movement
                    float hash1 = frac(sin(starIndex * 9.87 + time * 0.2) * 1234.56);
                    float hash2 = frac(sin(starIndex * 43.21 + time * 0.4) * 1234.56);
                    float hash3 = frac(sin(starIndex * 76.54 + time * 0.6) * 1234.56);
                    
                    // More varied star positioning with slight rotation
                    float starAngle = hash1 * 6.28318 + time * 0.05;
                    float starDistance = 0.4 + hash2 * 1.0;
                    
                    // Faster, more varied animation
                    float starTime = frac(hash3 + time * _StarSpeed * 0.12);
                    float starDepth = starTime * 2.2;
                    
                    // Simple position calculation
                    float projectionFactor = 1.0 + starDepth * 0.2;
                    float2 starPos = float2(cos(starAngle), sin(starAngle)) * starDistance * projectionFactor;
                    
                    // Early exit for performance
                    if(length(starPos) > 1.5 || starDepth > 2.0) continue;
                    
                    // Ultra-simplified star calculation
                    float starDist = length(uv - starPos);
                    float starSize = _StarSize * (0.8 + hash2 * 0.3);
                    float star = exp(-starDist * 30.0 / starSize);
                    
                    // Minimal twinkling
                    float twinkle = 0.85 + 0.15 * sin(time + hash3 * 6.28);
                    star *= twinkle;
                    
                    // Simple brightness
                    float brightness = (1.0 - starDepth * 0.4);
                    starIntensity += star * brightness;
                }
                
                // Apply stars
                color = lerp(color, _StarColor, saturate(starIntensity * _StarBrightness));
                
                // === ULTRA-MINIMAL CENTER EFFECTS - QUEST 2 MAXIMUM PERFORMANCE ===
                // Minimal center glow
                float centerGlow = exp(-dist * 1.5) * 0.4;
                color.rgb += centerGlow * beamColor.rgb;
                
                // Simple center core
                float centerCore = exp(-dist * 4.0) * 0.8;
                color.rgb += centerCore * float3(1.0, 1.0, 1.0);
                
                // Minimal tunnel depth
                float tunnelDepth = 1.0 - smoothstep(0.0, 0.5, dist);
                float tunnelGlow = tunnelDepth * 0.2;
                color.rgb += tunnelGlow * float3(0.8, 0.9, 1.0);
                
                return color;
            }
            ENDCG
        }
    }
}