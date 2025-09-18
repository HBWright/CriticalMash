Shader "Skybox/SpaceSkybox"
{
    Properties
    {
        _BackgroundColor ("Background Color", Color) = (0.01, 0.01, 0.05, 1)
        
        // Star field properties
        _StarDensity ("Star Density", Range(2.0, 20.0)) = 8.0
        _StarBrightness ("Star Brightness", Range(0.1, 3.0)) = 1.2
        _StarColor ("Star Color", Color) = (1,1,1,1)
        _StarTwinkleSpeed ("Star Twinkle Speed", Range(0.1, 2.0)) = 0.5
        _StarMovementSpeed ("Star Movement Speed", Range(0.0, 1.0)) = 0.1
        
        // Nebula properties
        _NebulaColor1 ("Nebula Color 1", Color) = (0.2, 0.1, 0.4, 1)
        _NebulaColor2 ("Nebula Color 2", Color) = (0.4, 0.2, 0.6, 1)
        _NebulaIntensity ("Nebula Intensity", Range(0.0, 1.0)) = 0.3
        _NebulaScale ("Nebula Scale", Range(0.5, 5.0)) = 2.0
        _NebulaSpeed ("Nebula Movement Speed", Range(0.0, 0.5)) = 0.05
        
        // Distant galaxy properties
        _GalaxyIntensity ("Distant Galaxy Intensity", Range(0.0, 0.5)) = 0.15
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
            
            // Fractal noise for nebula effects
            float fbm(float3 p, int octaves)
            {
                float value = 0.0;
                float amplitude = 0.5;
                float frequency = 1.0;
                
                for(int i = 0; i < octaves; i++)
                {
                    value += amplitude * noise3D(p * frequency);
                    amplitude *= 0.5;
                    frequency *= 2.0;
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
                
                // === NEBULA BACKGROUND ===
                float3 nebulaPos = viewDir * _NebulaScale + float3(time * _NebulaSpeed, time * _NebulaSpeed * 0.7, time * _NebulaSpeed * 0.3);
                float nebula = fbm(nebulaPos, 4);
                nebula = smoothstep(0.3, 0.8, nebula);
                
                float4 nebulaColor = lerp(_NebulaColor1, _NebulaColor2, nebula);
                color = lerp(color, nebulaColor, nebula * _NebulaIntensity);
                
                // === DISTANT GALAXY GLOW ===
                float3 galaxyPos = viewDir * 0.8;
                float galaxy = fbm(galaxyPos, 3);
                galaxy = pow(max(0.0, galaxy - 0.4), 2.0);
                color = lerp(color, _GalaxyColor, galaxy * _GalaxyIntensity);
                
                // === STAR FIELD ===
                float starField = 0.0;
                
                // Multiple star layers at different scales - MORE LAYERS!
                for(int layer = 0; layer < 5; layer++) // Increased from 3 to 5 layers
                {
                    float layerScale = pow(2.0, float(layer)) * _StarDensity;
                    float3 starPos = viewDir * layerScale;
                    
                    // Add slow movement
                    starPos += float3(time * _StarMovementSpeed * (0.5 + float(layer) * 0.2), 
                                     time * _StarMovementSpeed * (0.3 + float(layer) * 0.15),
                                     time * _StarMovementSpeed * (0.7 + float(layer) * 0.1));
                    
                    // Create star positions
                    float3 starGrid = floor(starPos);
                    float3 starFrac = frac(starPos);
                    
                    // Random star in each grid cell - BIGGER SEARCH AREA
                    for(int x = -2; x <= 2; x++) // Increased from -1,1 to -2,2
                    {
                        for(int y = -2; y <= 2; y++)
                        {
                            for(int z = -2; z <= 2; z++)
                            {
                                float3 cellOffset = float3(x, y, z);
                                float3 cellPos = starGrid + cellOffset;
                                
                                float3 starHash = hash3(cellPos.x + cellPos.y * 157.0 + cellPos.z * 113.0);
                                
                                // Random star position within cell
                                float3 starLocalPos = starHash;
                                float3 starWorldPos = cellPos + starLocalPos;
                                
                                // Distance to star
                                float3 toStar = starPos - starWorldPos;
                                float starDist = length(toStar);
                                
                                // MORE STARS - Lower threshold so more stars are visible
                                float starThreshold = 0.65 - float(layer) * 0.1; // Different thresholds per layer
                                if(starHash.z > starThreshold) // Much more stars now visible
                                {
                                    // Create star
                                    float starSize = 0.08 + starHash.x * 0.12; // Slightly varied sizes
                                    float star = exp(-starDist * 15.0 / starSize); // Adjusted falloff
                                    
                                    // Twinkling effect
                                    float twinkle = 0.6 + 0.4 * sin(time * _StarTwinkleSpeed * (2.0 + starHash.y * 5.0) + starHash.x * 6.28318);
                                    star *= twinkle;
                                    
                                    // Size variation based on layer (distant stars smaller)
                                    star *= (1.2 - float(layer) * 0.15);
                                    
                                    starField += star;
                                }
                            }
                        }
                    }
                }
                
                // Apply star field
                color = lerp(color, _StarColor, saturate(starField * _StarBrightness));
                
                // === ATMOSPHERIC GLOW ===
                // Add subtle color variation based on viewing direction
                float atmosphereGlow = abs(viewDir.y) * 0.1;
                color.rgb += atmosphereGlow * float3(0.1, 0.05, 0.2);
                
                return color;
            }
            ENDCG
        }
    }
}