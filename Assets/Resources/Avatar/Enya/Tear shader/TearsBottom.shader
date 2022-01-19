// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TearsBottom"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_tears_mask("tears_mask", 2D) = "white" {}
		_tears_outline("tears_outline", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , One Zero
		BlendOp Add , Add
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _tears_outline;
		uniform sampler2D _tears_mask;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _Cutoff = 0.5;


		inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }

		inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }

		inline float valueNoise (float2 uv)
		{
			float2 i = floor(uv);
			float2 f = frac( uv );
			f = f* f * (3.0 - 2.0 * f);
			uv = abs( frac(uv) - 0.5);
			float2 c0 = i + float2( 0.0, 0.0 );
			float2 c1 = i + float2( 1.0, 0.0 );
			float2 c2 = i + float2( 0.0, 1.0 );
			float2 c3 = i + float2( 1.0, 1.0 );
			float r0 = noise_randomValue( c0 );
			float r1 = noise_randomValue( c1 );
			float r2 = noise_randomValue( c2 );
			float r3 = noise_randomValue( c3 );
			float bottomOfGrid = noise_interpolate( r0, r1, f.x );
			float topOfGrid = noise_interpolate( r2, r3, f.x );
			float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
			return t;
		}


		float SimpleNoise(float2 UV)
		{
			float t = 0.0;
			float freq = pow( 2.0, float( 0 ) );
			float amp = pow( 0.5, float( 3 - 0 ) );
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(1));
			amp = pow(0.5, float(3-1));
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(2));
			amp = pow(0.5, float(3-2));
			t += valueNoise( UV/freq )*amp;
			return t;
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 panner35 = ( 1.0 * _Time.y * float2( 0,0.5 ) + i.uv_texcoord);
			float clampResult16 = clamp( (-1.0 + (( tex2D( _tears_outline, panner35, float2( 0,0 ), float2( 0,0 ) ).r * 4.0 ) - 0.0) * (2.0 - -1.0) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float4 tex2DNode116 = tex2D( _tears_mask, panner35, float2( 0,0 ), float2( 0,0 ) );
			float clampResult17 = clamp( ( tex2DNode116.r * 0.1 ) , 0.0 , 1.0 );
			float clampResult21 = clamp( ( clampResult16 + clampResult17 ) , 0.0 , 1.0 );
			float temp_output_130_0 = (i.uv_texcoord).y;
			float clampResult136 = clamp( ( (0.0 + (temp_output_130_0 - 0.0) * (0.6 - 0.0) / (1.0 - 0.0)) * (-1.0 + (temp_output_130_0 - 0.0) * (1.3 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float2 panner62 = ( 1.0 * _Time.y * float2( 0.5,0.5 ) + i.uv_texcoord);
			float simpleNoise87 = SimpleNoise( panner62*40.0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor58 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( tex2DNode116.r * clampResult136 * (0.1 + (simpleNoise87 - 0.0) * (-0.1 - 0.1) / (1.0 - 0.0)) ) + (ase_grabScreenPosNorm).xy ));
			float3 clampResult2 = clamp( ( ( clampResult21 * clampResult136 ) + (screenColor58).rgb ) , float3( 0,0,0 ) , float3( 1,1,1 ) );
			o.Emission = clampResult2;
			o.Alpha = 1;
			clip( tex2DNode116.r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
0;84;2560;1294;4842.883;961.5183;1.690905;True;True
Node;AmplifyShaderEditor.CommentaryNode;141;-4230.908,321.5372;Inherit;False;1330.5;640.3434;Fade In/Out;6;134;129;133;135;130;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;120;-4666.862,-377.7698;Inherit;False;2085.706;681.7268;Main;11;34;35;117;118;116;80;12;16;17;19;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;119;-3923.852,984.6635;Inherit;False;1034.634;349;Noise;4;87;52;62;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-4616.862,-121.2908;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;-4180.908,560.2126;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;35;-4360.866,-121.2908;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-3873.852,1034.663;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;130;-3946.405,561.2125;Inherit;True;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;62;-3646.235,1036.28;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;134;-3655.409,461.213;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;133;-3655.409,684.2128;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;-4065.813,-326.0483;Inherit;True;Property;_tears_outline;tears_outline;2;0;Create;True;0;0;False;0;-1;5d0f4e4920a6fe344b16be128b2b2845;5d0f4e4920a6fe344b16be128b2b2845;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-3775.693,-327.7698;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;87;-3414.431,1034.981;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;40;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;116;-4055.337,73.95699;Inherit;True;Property;_tears_mask;tears_mask;1;0;Create;True;0;0;False;0;-1;09a3e34ca8eff9d4db276dc361c76224;09a3e34ca8eff9d4db276dc361c76224;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;67;-3117.998,1373.469;Inherit;False;1288.918;304.3845;Grab Screen;5;53;55;57;58;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-3363.407,551.213;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;136;-3156.409,555.213;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;-3571.318,-326.3162;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-3568.927,-79.51841;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;53;-3067.998,1443.908;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;52;-3183.219,1040.481;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;4;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;16;-3314.322,-325.7347;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;17;-3311.198,-73.92643;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-2800.161,557.792;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;55;-2813.999,1445.908;Inherit;True;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-2539.867,1424.853;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-3050.803,-188.334;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;21;-2837.159,-187.8459;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;58;-2278.245,1430.476;Inherit;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2081.219,67.75796;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;59;-2066.08,1423.468;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-1843.037,66.94765;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;2;-1623.337,67.8858;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;142;-1413.962,-32.12704;Inherit;False;313;505;Ver 20.08.23;1;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1363.962,17.87296;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TearsBottom;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;1;1;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;35;0;34;0
WireConnection;130;0;129;0
WireConnection;62;0;61;0
WireConnection;134;0;130;0
WireConnection;133;0;130;0
WireConnection;117;1;35;0
WireConnection;118;0;117;1
WireConnection;87;0;62;0
WireConnection;116;1;35;0
WireConnection;135;0;134;0
WireConnection;135;1;133;0
WireConnection;136;0;135;0
WireConnection;12;0;118;0
WireConnection;80;0;116;1
WireConnection;52;0;87;0
WireConnection;16;0;12;0
WireConnection;17;0;80;0
WireConnection;56;0;116;1
WireConnection;56;1;136;0
WireConnection;56;2;52;0
WireConnection;55;0;53;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;19;0;16;0
WireConnection;19;1;17;0
WireConnection;21;0;19;0
WireConnection;58;0;57;0
WireConnection;23;0;21;0
WireConnection;23;1;136;0
WireConnection;59;0;58;0
WireConnection;4;0;23;0
WireConnection;4;1;59;0
WireConnection;2;0;4;0
WireConnection;0;2;2;0
WireConnection;0;10;116;1
ASEEND*/
//CHKSM=5616E2C13B5A241BD56BAD375A8E6B6E18F184F9