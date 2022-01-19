// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TearsTop"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_tears_outline("tears_outline", 2D) = "white" {}
		_tears_mask("tears_mask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
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
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _tears_mask;
		uniform float4 _tears_mask_ST;
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
			float2 panner38 = ( 1.0 * _Time.y * float2( 1,1 ) + i.uv_texcoord);
			float simpleNoise63 = SimpleNoise( panner38*30.0 );
			float temp_output_51_0 = ( 0.52 * tex2D( _tears_outline, ( i.uv_texcoord + (-0.01 + (simpleNoise63 - 0.0) * (0.01 - -0.01) / (1.0 - 0.0)) ), float2( 0,0 ), float2( 0,0 ) ).r );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor29 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( temp_output_51_0 * (0.2 + (simpleNoise63 - 0.0) * (-0.2 - 0.2) / (1.0 - 0.0)) ) + (ase_grabScreenPosNorm).xy ));
			o.Emission = ( temp_output_51_0 + (screenColor29).rgb );
			o.Alpha = 1;
			float2 uv_tears_mask = i.uv_texcoord * _tears_mask_ST.xy + _tears_mask_ST.zw;
			clip( tex2D( _tears_mask, uv_tears_mask, float2( 0,0 ), float2( 0,0 ) ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18000
0;84;2560;1294;2837.977;289.6646;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;68;-4221.22,195.1847;Inherit;False;2060.151;589.7695;Main;9;53;38;63;49;56;60;45;51;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;-4171.22,247.322;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;38;-3911.635,378.0748;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;63;-3657.408,378.1942;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;30;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;49;-3392.002,307.4949;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.01;False;4;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-3131.375,245.1847;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;69;-2712.124,464.0173;Inherit;False;1252.581;495.2631;Grah Screen;6;30;44;47;29;27;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;60;-2930.713,250.9759;Inherit;True;Property;_tears_outline;tears_outline;1;0;Create;True;0;0;False;0;-1;14fd0618eadf8694f8a7d2e87e66285a;14fd0618eadf8694f8a7d2e87e66285a;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;45;-3393.002,531.9542;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2641.87,254.108;Inherit;True;2;2;0;FLOAT;0.52;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;30;-2662.124,728.4803;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-2396.069,511.5878;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;44;-2428.927,729.2804;Inherit;True;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-2133.665,514.0173;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;29;-1914.664,515.6173;Inherit;False;Global;_GrabScreen2;Grab Screen 2;6;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;27;-1739.103,517.4351;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1468.014,265.9612;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;70;-1299.322,168.3384;Inherit;False;313;505;Ver 20.08.23;1;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;62;-1785.543,715.7706;Inherit;True;Property;_tears_mask;tears_mask;2;0;Create;True;0;0;False;0;-1;65c7a2a572fa4e84ab2688eaf0012e11;65c7a2a572fa4e84ab2688eaf0012e11;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1249.322,218.3384;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TearsTop;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;38;0;53;0
WireConnection;63;0;38;0
WireConnection;49;0;63;0
WireConnection;56;0;53;0
WireConnection;56;1;49;0
WireConnection;60;1;56;0
WireConnection;45;0;63;0
WireConnection;51;1;60;1
WireConnection;36;0;51;0
WireConnection;36;1;45;0
WireConnection;44;0;30;0
WireConnection;47;0;36;0
WireConnection;47;1;44;0
WireConnection;29;0;47;0
WireConnection;27;0;29;0
WireConnection;41;0;51;0
WireConnection;41;1;27;0
WireConnection;0;2;41;0
WireConnection;0;10;62;1
ASEEND*/
//CHKSM=36BF30BDA8BD5D547D650117D5FA8479D7685F05