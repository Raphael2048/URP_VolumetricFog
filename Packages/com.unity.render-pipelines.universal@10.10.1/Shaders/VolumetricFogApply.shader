Shader "Unlit/VolumeApply"
{   
	SubShader
	{
		Pass 
		{
			ZTest Always Cull Off ZWrite Off
			Blend One SrcAlpha

			HLSLPROGRAM
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#pragma multi_compile_local _ _IgnoreSkybox
			#pragma vertex vert
			#pragma fragment frag
			
			TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);
			
			struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv        : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;
                output.uv = input.uv;

                return output;
            }
			
			float4 frag(Varyings input) : SV_Target
            {
            	float z = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv);
            	#if _IgnoreSkybox
            		if (z == UNITY_RAW_FAR_CLIP_VALUE)
            			return float4(0, 0, 0, 1);
            	#endif

            	float4 AccumulatedLighting = SampleVolumetricFog(input.uv, z);
            	return AccumulatedLighting;
			}

			ENDHLSL
		}
	}
}
