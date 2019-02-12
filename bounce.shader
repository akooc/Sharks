Shader "Gooest/LBM/bounce" {

	Properties {
		_Diffuse1 ("Diffuse Texture 1", 2D) = "" {}
		_Diffuse2 ("Diffuse Texture 2", 2D) = "" {}
		_Diffuse3 ("Diffuse Texture 3", 2D) = "" {}
		_obstaclesTex ("_obstaclesTex", 2D) = "" {}
		_Viscosity ("_Viscosity", float) = 0.1
		_FlowSpeed ("_FlowSpeed", float) = 0.1
		_T ("time", float) = 0.0
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	uniform sampler2D _Diffuse1;
	uniform sampler2D _Diffuse2;
	uniform sampler2D _Diffuse3;
	uniform sampler2D _obstaclesTex;
	uniform float _Viscosity;
	uniform float _FlowSpeed;
	uniform float _T;
	uniform float2 _InverseSize;

	float4 compute1 (v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float x = uv.x;
		float y = uv.y;

		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

    //for (int x = 0; x < xdim; x++)
    //{
    //    for (int y = 0; y < ydim; y++)
    //    {
    //uint pos = x + xdim * y;
    if (ob.r == 1)
    {
        if (nN > 0)
        {
            //_directionBuffer[x + xdim * (y - 1)].nS += nN;
            nS += nN;
            nN = 0;
        }
        if (nS > 0)
        {
            //_directionBuffer[x + xdim * (y + 1)].nN += nS;
            nN += nS;
            nS = 0;
        }
        if (nE > 0)
        {
            //_directionBuffer[(x - 1) + xdim * y].nW += nE;
            nW += nE;
            nE = 0;
        }
        if (nW > 0)
        {
            //_directionBuffer[(x + 1) + xdim * y].nE += nW;
            nE += nW;
            nW = 0;
        }
        if (nNW > 0)
        {
            //_directionBuffer[(x + 1) + xdim * (y - 1)].nSE += nNW;
            nSE += nNW;
            nNW = 0;
        }
        if (nNE > 0)
        {
            //_directionBuffer[(x - 1) + xdim * (y - 1)].nSW += nNE;
            nSW += nNE;
            nNE = 0;
        }
        if (nSW > 0)
        {
            //_directionBuffer[(x + 1) + xdim * (y + 1)].nNE += nSW;
            nNE += nSW;
            nSW = 0;
        }
        if (nSE > 0)
        {
            //_directionBuffer[(x - 1) + xdim * (y + 1)].nNW += nSE;
            nNW += nSE;
            nSE = 0;
        }
    }
    //    }
    //}

              
		return float4(n0, nE, nW, 1.0);
	}
	
	float4 compute2(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float x = uv.x;
		float y = uv.y;

		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

		if (ob.r == 1)
		{
			if (nN > 0)
			{
				nS += nN;
				nN = 0;
			}
			if (nS > 0)
			{
				nN += nS;
				nS = 0;
			}
			if (nE > 0)
			{
				nW += nE;
				nE = 0;
			}
			if (nW > 0)
			{
				nE += nW;
				nW = 0;
			}
			if (nNW > 0)
			{
				nSE += nNW;
				nNW = 0;
			}
			if (nNE > 0)
			{
				nSW += nNE;
				nNE = 0;
			}
			if (nSW > 0)
			{
				nNE += nSW;
				nSW = 0;
			}
			if (nSE > 0)
			{
				nNW += nSE;
				nSE = 0;
			}
		}
		return float4(nN, nS, nNE, 1.0);
	}
	
	float4 compute3(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float x = uv.x;
		float y = uv.y;

		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

		if (ob.r == 1)
		{
			if (nN > 0)
			{
				nS += nN;
				nN = 0;
			}
			if (nS > 0)
			{
				nN += nS;
				nS = 0;
			}
			if (nE > 0)
			{
				nW += nE;
				nE = 0;
			}
			if (nW > 0)
			{
				nE += nW;
				nW = 0;
			}
			if (nNW > 0)
			{
				nSE += nNW;
				nNW = 0;
			}
			if (nNE > 0)
			{
				nSW += nNE;
				nNE = 0;
			}
			if (nSW > 0)
			{
				nNE += nSW;
				nSW = 0;
			}
			if (nSE > 0)
			{
				nNW += nSE;
				nSE = 0;
			}
		}

		return float4(nSE, nNW, nSW, 1.0);
	}
	
	
	ENDCG
	
	SubShader {
	
		Pass {
			Fog { Mode Off }
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment compute1
			ENDCG
		}
		
		Pass {
			Fog { Mode Off }
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment compute2
			ENDCG
		}
		
		Pass {
			Fog { Mode Off }
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment compute3
			ENDCG
		}		
	} 
	
	FallBack "Diffuse"
}
