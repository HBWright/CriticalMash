Shader "Skybox/SpaceSkybox"
{
    Properties
    {
        _BackgroundColor ("Background Color", Color) = (0.01, 0.01, 0.05, 1)
        
        // Star field properties
        _StarDensity ("Star Density", Range(2.0, 8.0)) = 4.0
        _StarBrightness ("Star Brightness", Range(0.1, 2.5)) = 1.2
        _StarColor ("Star Color", Color) = (1,1,1,1)
        _StarTwinkleSpeed ("Star Twinkle Speed", Range(0.1, 1.5)) = 0.4
        _StarMovementSpeed ("Star Movement Speed", Range(0.0, 0.5)) = 0.08
        
        // Nebula properties
        _NebulaColor1 ("Nebula Color 1", Color) = (0.2, 0.1, 0.4, 1)
        _NebulaColor2 ("Nebula Color 2", Color) = (0.4, 0.2, 0.6, 1)
        _NebulaIntensity ("Nebula Intensity", Range(0.0, 0.8)) = 0.25
        _NebulaScale ("Nebula Scale", Range(0.5, 3.0)) = 1.5
        _NebulaSpeed ("Nebula Movement Speed", Range(0.0, 0.3)) = 0.03
        
        // Distant galaxy properties
        _GalaxyIntensity ("Distant Galaxy Intensity", Range(0.0, 0.4)) = 0.2
        _GalaxyColor ("Galaxy Color", Color) = (0.8, 0.9, 1.0, 1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Skybox" }
        LOD 100
        
        Cull Off
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };
            
            float4 _BackgroundColor;
            
            // Star variables
            float _StarDensity;
            float _StarBrightness;
            float4 _StarColor;
            float _StarTwinkleSpeed;
            float _StarMovementSpeed;
            
            // Nebula variables
            float4 _NebulaColor1;
            float4 _NebulaColor2;
            float _NebulaIntensity;
            float _NebulaScale;
            float _NebulaSpeed;
            
            // Galaxy variables
            float _GalaxyIntensity;
            float4 _GalaxyColor;
            
            // Hash functions for procedural generation
            float hash(float n)
            {
                return frac(sin(n) * 43758.5453);
            }
            
            float hash2(float2 n)
            {
                return frac(sin(dot(n, float2(127.1, 311.7))) * 43758.5453);
            }
            
            float3 hash3(float n)
            {
                return frac(sin(float3(n, n + 1.0, n + 2.0)) * float3(43758.5453, 22578.1459, 19642.3490));
            }
            
            // 3D Noise function
            float noise3D(float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                
                float n = i.x + i.y * 157.0 + i.z * 113.0;
                
                return lerp(lerp(lerp(hash(n), hash(n + 1.0), f.x),
                              lerp(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
                          lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
                              lerp(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
            }
            
            // Fractal noise for nebula effects - SIMPLIFIED FOR VR
            float fbm(float3 p, int octaves)
            {
                float value = 0.0;
                float amplitude = 0.5;
                
                // Only do 2 octaves max for VR performance
                octaves = min(octaves, 2);
                
                for(int i = 0; i < octaves; i++)
                {
                    value += amplitude * noise3D(p);
                    amplitude *= 0.5;
                    p *= 2.0;
                }
                
                return value;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = v.vertex.xyz;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(i.worldPos);
                float time = _Time.y;
                
                float4 color = _BackgroundColor;
                
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
                
                // Only render space effects for main VR player camera
                if (isMainVRCamera)
                {
                    // === NEBULA BACKGROUND - IMPROVED ===
                    float3 nebulaPos = viewDir * _NebulaScale + float3(time * _NebulaSpeed, time * _NebulaSpeed * 0.7, time * _NebulaSpeed * 0.2);
                    float nebula = fbm(nebulaPos, 2); // Still 2 octaves for performance
                    nebula = smoothstep(0.3, 0.8, nebula); // Better contrast
                    
                    float4 nebulaColor = lerp(_NebulaColor1, _NebulaColor2, nebula);
                    color = lerp(color, nebulaColor, nebula * _NebulaIntensity);
                    
                    // === DISTANT GALAXY GLOW - IMPROVED ===
                    float3 galaxyPos = viewDir * 0.7; // Better scale
                    float galaxy = fbm(galaxyPos, 2); // Add back some complexity
                    galaxy = pow(max(0.0, galaxy - 0.4), 1.8);
                    color = lerp(color, _GalaxyColor, galaxy * _GalaxyIntensity);
                    
                    // === STAR FIELD - OPTIMIZED BUT PRETTIER ===
                    float starField = 0.0;
                    
                    // 3 star layers for better depth
                    for(int layer = 0; layer < 3; layer++)
                    {
                        float layerScale = (1.0 + float(layer) * 1.5) * _StarDensity;
                        float3 starPos = viewDir * layerScale;
                        
                        // Subtle movement
                        starPos += float3(time * _StarMovementSpeed * (0.2 + float(layer) * 0.1), 
                                         time * _StarMovementSpeed * (0.15 + float(layer) * 0.08),
                                         time * _StarMovementSpeed * 0.05);
                        
                        // Create star positions
                        float3 starGrid = floor(starPos);
                        
                        // Reasonable search area
                        for(int x = -1; x <= 1; x++)
                        {
                            for(int y = -1; y <= 1; y++)
                            {
                                for(int z = -1; z <= 1; z++)
                                {
                                    float3 cellOffset = float3(x, y, z);
                                    float3 cellPos = starGrid + cellOffset;
                                    
                                    float starHash = hash2(cellPos.xy + cellPos.z * 13.7);
                                    
                                    // More stars but still controlled
                                    float starThreshold = 0.75 - float(layer) * 0.1;
                                    if(starHash > starThreshold)
                                    {
                                        // Random star position within cell
                                        float3 starHash3 = hash3(cellPos.x + cellPos.y * 157.0 + cellPos.z * 113.0);
                                        float3 starLocalPos = starHash3;
                                        float3 starWorldPos = cellPos + starLocalPos;
                                        
                                        // Distance to star
                                        float starDist = length(starPos - starWorldPos);
                                        
                                        // Variable star sizes
                                        float starSize = 0.06 + starHash3.y * 0.08;
                                        float star = exp(-starDist * 18.0 / starSize);
                                        
                                        // Enhanced twinkling
                                        float twinkle = 0.6 + 0.4 * sin(time * _StarTwinkleSpeed * (1.5 + starHash * 3.0) + starHash * 6.28);
                                        star *= twinkle;
                                        
                                        // Layer brightness variation
                                        star *= (1.5 - float(layer) * 0.2);
                                        
                                        starField += star;
                                    }
                                }
                            }
                        }
                    }
                    
                    // Apply star field
                    color = lerp(color, _StarColor, saturate(starField * _StarBrightness));
                    
                    // === SUBTLE ATMOSPHERIC GLOW ===
                    float atmosphereGlow = abs(viewDir.y) * 0.08;
                    color.rgb += atmosphereGlow * float3(0.08, 0.04, 0.15);
                }
                
                return color;
            }
            ENDCG
        }
    }
}