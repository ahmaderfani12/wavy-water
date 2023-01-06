#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "WaterPublicFuncs.hlsl"


float GetObjectDepth(float4 screenPos)
{
    float rawDepth = SampleSceneDepth(screenPos.xy / screenPos.w);
    float sceneEyeDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
    return sceneEyeDepth - screenPos.w;

}

float GetFoam(float foamNoiseScale, float step, float foamStep, float foamStepSmooth,
            sampler2D foamTexture,float foamTextureScale,float foamTextureStep, float foamTextureSmooth,
            float objectFoamFac1, float objectFoamFac2,float2 uv, float depthIn)
{
    
    // Noise 1 (Better to use texture here too)
    float desiredDepth = 1.0 -  (1.0 - saturate(depthIn * objectFoamFac1)) * objectFoamFac2;
    float noise = Unity_GradientNoise(uv, foamNoiseScale);
    
    noise = noise + desiredDepth + step;
    
    noise =1.0 -  smoothstep(foamStep, foamStep + foamStepSmooth,noise);

    // Noise2
    float noiseTexture = tex2D(foamTexture, uv*foamTextureScale).x;
    noiseTexture = 1.0 - smoothstep(foamTextureStep, foamTextureStep + foamTextureSmooth, noiseTexture);
    
    return noise * noiseTexture;    
}