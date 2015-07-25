//@author: grandchild
//@help: fills black spots in the kinect depth image
//@tags: kinect depth
//@credits: 

Texture2D texOld <string uiname="DepthBuffer";>;
Texture2D texNew <string uiname="DepthNew";>;

float2 texSize <string uiname="TextureSizeXY";>;
float threshold <string uiname="Threshold";>;
float confidenceFade <string uiname="Fade";>;

SamplerState samplePoint <string uiname="Sampler State";>
{
	Filter = MIN_MAG_MIP_POINT;
	AddressU = Clamp;
	AddressV = Clamp;
};

float2 PSFillPreferNeighbor(float4 PosWVP:SV_POSITION, float2 texCd:TEXCOORD0): SV_Target {
	float c_n  = texNew.Sample(samplePoint, texCd.xy).r;
	if(c_n.r > threshold) {
		return float2(c_n.r, 1.0f);
	}
	
	float2 c_o  = texOld.Sample(samplePoint, texCd.xy).rg;
	float confidence = c_o.g;
	if(c_o.r > threshold && confidence > 0.0f) {
		return float2(c_o.r, confidence - confidenceFade*0.1f);
	}
	
	float2 texelSize =  (float2)1.0f / texSize;
	float2 neighbOld[8];
	neighbOld[0] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2(-1, -1)).rg;
	neighbOld[1] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2( 0, -1)).rg;
	neighbOld[2] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2( 1, -1)).rg;
	neighbOld[3] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2(-1,  0)).rg;
	neighbOld[4] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2( 1,  0)).rg;
	neighbOld[5] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2(-1,  1)).rg;
	neighbOld[6] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2( 0,  1)).rg;
	neighbOld[7] = texOld.Sample(samplePoint, texCd.xy + texelSize*float2( 1,  1)).rg;
	
	float depth = 0.0f;
	confidence = 0.0f;
	int validNeighbors = 0;
	for(int i=0; i<8; i++) {
		if(neighbOld[i].r > threshold) {
			validNeighbors++;
			depth += neighbOld[i].r;
			confidence += neighbOld[i].g;
		}
	}
	depth /= float(validNeighbors);
	confidence /= float(validNeighbors) * 2.0f;
	return float2(depth, confidence - confidenceFade*0.1f);
}

float2 PSFillPreferOld(float4 PosWVP:SV_POSITION, float2 texCd:TEXCOORD0): SV_Target {
	float c_n  = texNew.Sample(samplePoint, texCd.xy).r;
	if(c_n.r > threshold) {
		return float2(c_n.r, 1.0f);
	}
	
	float2 texelSize =  (float2)1.0f / texSize;
	float2 neighbNew[8];
	neighbNew[0] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2(-1, -1)).rg;
	neighbNew[1] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2( 0, -1)).rg;
	neighbNew[2] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2( 1, -1)).rg;
	neighbNew[3] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2(-1,  0)).rg;
	neighbNew[4] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2( 1,  0)).rg;
	neighbNew[5] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2(-1,  1)).rg;
	neighbNew[6] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2( 0,  1)).rg;
	neighbNew[7] = texNew.Sample(samplePoint, texCd.xy + texelSize*float2( 1,  1)).rg;
	
	float depth = 0.0f;
	float confidence = 0.0f;
	int validNeighbors = 0;
	for(int i=0; i<8; i++) {
		if(neighbNew[i].r > threshold) {
			validNeighbors++;
			depth += neighbNew[i].r;
			confidence += max(confidenceFade*0.5f, neighbNew[i].g);
		}
	}
	depth /= float(validNeighbors);
	confidence /= float(validNeighbors) * 2.0f;
	if(depth > threshold && confidence > 0.0f) {
		return float2(depth, confidence - confidenceFade*0.1f);
	}
	
	float2 c_o  = texOld.Sample(samplePoint, texCd.xy).rg;
	confidence = c_o.g;
	return float2(c_o.r, confidence - confidenceFade*0.1f);
}

technique10 FillPreferOld
{ pass P0 { SetPixelShader( CompileShader( ps_4_0, PSFillPreferOld() ) ); } }

technique10 FillPreferNeighbor
{ pass P0 { SetPixelShader( CompileShader( ps_4_0, PSFillPreferNeighbor() ) ); } }
