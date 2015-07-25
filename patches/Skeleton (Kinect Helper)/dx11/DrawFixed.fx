//@author: antokhio 
//@help: template
//@tags: template 
//@credits: vvvv

float4x4 tW : WORLD;
float4x4 tVP : VIEWPROJECTION;


float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

struct vsIn
{
	float4 pos : POSITION;

};

struct vs2ps
{
    float4 pos: SV_POSITION;
};

vs2ps VS(vsIn input)
{
    vs2ps output = (vs2ps)0;
    output.pos  = mul(input.pos,mul(tW,tVP));
    return output;
}

float4 PS(vs2ps input): SV_Target
{
    float4 col =  cAmb;
    return col;
}

technique10 Template
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




