//--------------------------------------------------------------
//              Sunao Shader Geometry
//                      Copyright (c) 2021 揚茄子研究所
//--------------------------------------------------------------


[maxvertexcount(9)]
void geom(triangle VOUT IN[3] , inout TriangleStream<VOUT> GOUT) {

	VOUT o;

	#ifdef SURFACE
		if (_Culling != 1) {
			[unroll]
			for (int cnt = 0; cnt <= 2; cnt++) {
				o          = IN[cnt];

				GOUT.Append(o);
			}
			GOUT.RestartStrip();
		}

		if (_Culling <  2) {
			[unroll]
			for (int cnt = 2; cnt >= 0; cnt--) {
				o          = IN[cnt];
				o.normal   = -o.normal;
				o.normal.w = 0.0f;

				GOUT.Append(o);
			}
			GOUT.RestartStrip();
		}
	#endif

	#ifdef OUTLINE
		if (_OutLineEnable) {

			float4 OutLineScale;
			       OutLineScale.x  = length(float3(unity_ObjectToWorld[0].x , unity_ObjectToWorld[1].x , unity_ObjectToWorld[2].x));
			       OutLineScale.y  = length(float3(unity_ObjectToWorld[0].y , unity_ObjectToWorld[1].y , unity_ObjectToWorld[2].y));
			       OutLineScale.z  = length(float3(unity_ObjectToWorld[0].z , unity_ObjectToWorld[1].z , unity_ObjectToWorld[2].z));
			       OutLineScale.w  = 1.0f;
			       OutLineScale    = 0.01f / OutLineScale;
			       OutLineScale   *= _OutLineSize;
			if (_OutLineFixScale) OutLineScale *= 10.0f;

			float4 VertexAdd;
			float  OutlineMask;

			[unroll]
			for (int cnt = 2; cnt >= 0; cnt--) {
				o           = IN[cnt];
				o.normal.w  = -1.0f;
				
				OutlineMask = MonoColor(tex2Dlod(_OutLineMask , float4(o.uv.xy , 0.0f , 0.0f)).rgb);
				VertexAdd   = float4(o.normal.xyz , 0) * OutlineMask;
				VertexAdd  *= OutLineScale;

				o.vertex   += VertexAdd;
				o.pos       = UnityObjectToClipPos(o.vertex);
				o.wpos      = mul(unity_ObjectToWorld , o.vertex).xyz;

				GOUT.Append(o);
			}
			GOUT.RestartStrip();
		}
	#endif

}
