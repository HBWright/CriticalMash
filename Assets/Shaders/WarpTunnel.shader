Shader "Custom/Hyperwarp"
{
    Properties
    {
        _Speed ("Warp Speed", Range(0.1, 10.0)) = 2.0
        _BackgroundColor ("Background Color", Color) = (0.0, 0.0, 0.0, 1)
        
        // Light beam properties
        _BeamCount ("Light Beam Count", Range(20, 200)) = 80
        _BeamBrightness ("Beam Brightness", Range(0.1, 5.0)) = 2.0
        _BeamColor1 ("Beam Color 1", Color) = (1.0, 1.0, 1.0, 1) // White
        _BeamColor2 ("Beam Color 2", Color) = (0.9, 0.9, 1.0, 1) // Slightly blue-white
        _BeamThickness ("Beam Thickness", Range(0.001, 0.05)) = 0.01
        _BeamLength ("Beam Length", Range(0.1, 2.0)) = 1.0
        _CenterSize ("Center Hole Size", Range(0.0, 0.3)) = 0.1
        
        // Star properties
        _StarCount ("Star Count", Range(50, 500)) = 200
        _StarBrightness ("Star Brightness", Range(0.1, 3.0)) = 1.5
        _StarColor ("Star Color", Color) = (1,1,1,1)
        _StarSpeed ("Star Speed", Range(0.1, 2.0)) = 0.5
        _StarSize ("Star Size", Range(0.005, 0.03)) = 0.01
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
            
            // Hash function for procedural randomness
            float hash(float n)
            {
                return frac(sin(n) * 43758.5453);
            }
            
            float2 hash2(float n)
            {
                return frac(sin(float2(n, n + 1.0)) * float2(43758.5453, 22578.1459));
            }
            
            // Distance from point to line segment
            float distanceToLine(float2 p, float2 start, float2 end)
            {
                float2 pa = p - start;
                float2 ba = end - start;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h);
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
                // Convert UV to centered coordinates (-1 to 1)
                float2 uv = (i.uv - 0.5) * 2.0;
                
                float time = _Time.y * _Speed;
                float dist = length(uv);
                float angle = atan2(uv.y, uv.x);
                
                float4 color = _BackgroundColor;
                
                // === LIGHT BEAMS ===
                float beamIntensity = 0.0;
                
                for(int j = 0; j < _BeamCount; j++)
                {
                    float beamIndex = float(j);
                    
                    // Random angle for each beam (not evenly spaced)
                    float beamAngle = hash(beamIndex * 234.56) * 6.28318;
                    
                    // Random radial offset for beam placement
                    float beamOffset = hash(beamIndex * 567.89) * 0.3 + 0.1;
                    
                    // Calculate beam direction
                    float2 beamDir = float2(cos(beamAngle), sin(beamAngle));
                    
                    // Beam animation - moves from center outward to far, then resets (REVERSED)
                    float beamProgress = frac(hash(beamIndex * 789.12) + time * _Speed * 0.3);
                    
                    // Map progress to beam position (starts at center, moves outward)
                    float maxLength = 2.0;
                    float beamStart = _CenterSize + beamProgress * 0.5; // Tail of the beam
                    float beamEnd = _CenterSize + beamProgress * maxLength; // Head of the beam
                    
                    // Only show beam if it's within visible range
                    if(beamStart < maxLength && beamEnd > _CenterSize)
                    {
                        // Beam extends from center toward outer edge
                        float2 beamStartPos = beamDir * beamStart;
                        float2 beamEndPos = beamDir * beamEnd;
                        
                        // Calculate distance to beam line segment
                        float lineDistance = distanceToLine(uv, beamStartPos, beamEndPos);
                        
                        // Check if point is within the beam segment
                        float pointDist = length(uv);
                        float beamMask = step(beamStart, pointDist) * step(pointDist, beamEnd);
                        
                        // Create beam intensity
                        float beam = exp(-lineDistance / _BeamThickness) * beamMask;
                        
                        // Fade beam as it moves away from center
                        beam *= smoothstep(maxLength - 0.2, maxLength, beamEnd);
                        
                        // Brighten beam head (the leading edge moving outward)
                        float headDistance = abs(pointDist - beamEnd);
                        beam += exp(-headDistance / (_BeamThickness * 2.0)) * exp(-lineDistance / (_BeamThickness * 0.5)) * beamMask * 2.0;
                        
                        beamIntensity += beam;
                    }
                }
                
                // Color variation for beams
                float colorMix = sin(time * 0.5 + angle * 2.0) * 0.5 + 0.5;
                float4 beamColor = lerp(_BeamColor1, _BeamColor2, colorMix);
                
                // Apply beam color
                color = lerp(color, beamColor, saturate(beamIntensity * _BeamBrightness));
                
                // === STARS ===
                float starIntensity = 0.0;
                
                for(int k = 0; k < _StarCount; k++)
                {
                    float starIndex = float(k);
                    
                    // Multiple hash values for maximum randomness
                    float hash1 = hash(starIndex * 123.45);
                    float hash2 = hash(starIndex * 678.90);
                    float hash3 = hash(starIndex * 234.67);
                    float hash4 = hash(starIndex * 890.12);
                    float hash5 = hash(starIndex * 345.78);
                    
                    // Completely random angle (full 360 degrees)
                    float starAngle = hash1 * 6.28318;
                    
                    // Much more varied distance from center with multiple random factors
                    float baseDistance = 0.2 + hash2 * 3.0; // Base spread
                    float distanceVariation = hash3 * 1.5; // Additional random variation
                    float starDistance = baseDistance + distanceVariation;
                    
                    // Random depth with more variation
                    float depthOffset = hash4 * 12.0; // Different starting points for each star
                    float starDepth = frac(depthOffset + time * _StarSpeed * 0.2 * (0.5 + hash5 * 1.0)) * 6.0;
                    
                    // Random projection factor variation
                    float projectionVariation = 0.8 + hash3 * 0.4; // Each star projects slightly differently
                    float projectionFactor = (1.0 + starDepth * 0.5) * projectionVariation;
                    
                    // Apply random rotation offset to break up patterns
                    float rotationOffset = hash4 * 6.28318;
                    float finalAngle = starAngle + rotationOffset * 0.1;
                    
                    float2 starPos = float2(cos(finalAngle), sin(finalAngle)) * starDistance * projectionFactor;
                    
                    // More lenient visibility check to show more stars
                    if(length(starPos) < 4.0 && starDepth < 5.5)
                    {
                        // Distance to star
                        float starDist = length(uv - starPos);
                        
                        // Random size variation for each star
                        float sizeVariation = 0.7 + hash2 * 0.6; // Each star has different size
                        float starSizeAdjusted = _StarSize * sizeVariation * (1.0 + (5.5 - starDepth) * 0.2);
                        float star = exp(-starDist / starSizeAdjusted);
                        
                        // Random twinkling with different frequencies for each star
                        float twinkleSpeed = 1.5 + hash5 * 2.0;
                        float twinklePhase = hash3 * 6.28318;
                        star *= 0.7 + 0.3 * sin(time * twinkleSpeed + twinklePhase);
                        
                        // Random brightness variation
                        float brightnessVariation = 0.6 + hash4 * 0.8;
                        star *= (1.0 - starDepth * 0.15) * brightnessVariation;
                        
                        starIntensity += star;
                    }
                }
                
                // Apply stars
                color = lerp(color, _StarColor, saturate(starIntensity * _StarBrightness));
                
                // === CENTER GLOW & INFINITE TUNNEL ===
                // Create bright center point that fades to infinity
                float centerGlow = exp(-dist * 2.0) * 0.8;
                color.rgb += centerGlow * beamColor.rgb;
                
                // Create infinite tunnel effect - brighten the very center
                float infiniteCenter = exp(-dist * 8.0) * 1.5;
                color.rgb += infiniteCenter * float3(1.0, 1.0, 1.0);
                
                // === INFINITE VOID EFFECT ===
                // Instead of darkening edges, create infinite depth illusion
                float tunnelDepth = 1.0 - smoothstep(0.0, 0.8, dist);
                
                // Brighten center area to create "light at end of tunnel" effect
                float voidGlow = pow(tunnelDepth, 3.0) * 0.5;
                color.rgb += voidGlow * float3(0.8, 0.9, 1.0);
                
                // Fade to pure void at the very center
                float voidFade = smoothstep(0.0, 0.1, dist);
                color.rgb *= voidFade + (1.0 - voidFade) * 2.0; // Brighten center instead of darken
                
                return color;
            }
            ENDCG
        }
    }
}