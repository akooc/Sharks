Shader "Gooest/LBM/collide" {

	Properties {
		_Diffuse1 ("Diffuse Texture 1", 2D) = "" {}
		_Diffuse2 ("Diffuse Texture 2", 2D) = "" {}
		_Diffuse3 ("Diffuse Texture 3", 2D) = "" {}
		_obstaclesTex ("_obstaclesTex", 2D) = "" {}
		_rtOutPutTex ("_rtOutPutTex", 2D) = "" {}
		_Viscosity ("_Viscosity", float) = 0.1
		_T ("time", float) = 0.0
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	uniform sampler2D _Diffuse1;
	uniform sampler2D _Diffuse2;
	uniform sampler2D _Diffuse3;
	uniform sampler2D _obstaclesTex;
	uniform sampler2D _rtOutPutTex;
	uniform float _Viscosity;
	uniform float _T;

	float4 compute1 (v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		float4 ro = tex2D(_rtOutPutTex, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

		float density = ro.r;
		float xvel = ro.g;
		float yvel = ro.b;
		float speed2 = ro.a;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float omega = 1.0 / (3.0 * _Viscosity + 0.5); // reciprocal of tau, the relaxation time
        float n, one9thn, one36thn, vx, vy, vx2, vy2, vx3, vy3, vxvy2, v2, v215;

        n = n0 + nN + nS + nE + nW + nNW + nNE + nSW + nSE;
        density = n;      // macroscopic density may be needed for plotting
        one9thn = one9th * n;
        one36thn = one36th * n;
        if (n > 0)
        {
              vx = (nE + nNE + nSE - nW - nNW - nSW) / n;
        }
        else vx = 0.0;
              xvel = vx;        // may be needed for plotting
        if (n > 0)
        {
              vy = (nN + nNE + nNW - nS - nSE - nSW) / n;
        }
        else vy = 0.0;
        yvel = vy;        // may be needed for plotting
        vx3 = 3.0 * vx;
        vy3 = 3.0 * vy;
        vx2 = vx * vx;
        vy2 = vy * vy;
        vxvy2 = 2.0 * vx * vy;
        v2 = vx2 + vy2;
        speed2 = v2;      // may be needed for plotting
        v215 = 1.5 * v2;
        n0 += omega * (four9ths * n * (1.0 - v215) - n0);
        nE += omega * (one9thn * (1.0 + vx3 + 4.5 * vx2 - v215) - nE);
        nW += omega * (one9thn * (1.0 - vx3 + 4.5 * vx2 - v215) - nW);
        nN += omega * (one9thn * (1.0 + vy3 + 4.5 * vy2 - v215) - nN);
        nS += omega * (one9thn * (1.0 - vy3 + 4.5 * vy2 - v215) - nS);
        nNE += omega * (one36thn * (1.0 + vx3 + vy3 + 4.5 * (v2 + vxvy2) - v215) - nNE);
		nSE += omega * (one36thn * (1.0 + vx3 - vy3 + 4.5 * (v2 - vxvy2) - v215) - nSE);
        nNW += omega * (one36thn * (1.0 - vx3 + vy3 + 4.5 * (v2 - vxvy2) - v215) - nNW);
        nSW += omega * (one36thn * (1.0 - vx3 - vy3 + 4.5 * (v2 + vxvy2) - v215) - nSW);
              
		return (ob.r!=0)?float4(d1.r,d1.g,d1.b,1):float4(n0, nE, nW, 1.0);
	}
	
	float4 compute2(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		float4 ro = tex2D(_rtOutPutTex, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

		float density = ro.r;
		float xvel = ro.g;
		float yvel = ro.b;
		float speed2 = ro.a;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float omega = 1.0 / (3.0 * _Viscosity + 0.5); // reciprocal of tau, the relaxation time
        float n, one9thn, one36thn, vx, vy, vx2, vy2, vx3, vy3, vxvy2, v2, v215;

        n = n0 + nN + nS + nE + nW + nNW + nNE + nSW + nSE;
        density = n;      // macroscopic density may be needed for plotting
        one9thn = one9th * n;
        one36thn = one36th * n;
        if (n > 0)
        {
              vx = (nE + nNE + nSE - nW - nNW - nSW) / n;
        }
        else vx = 0.0;
              xvel = vx;        // may be needed for plotting
        if (n > 0)
        {
              vy = (nN + nNE + nNW - nS - nSE - nSW) / n;
        }
        else vy = 0.0;
        yvel = vy;        // may be needed for plotting
        vx3 = 3.0 * vx;
        vy3 = 3.0 * vy;
        vx2 = vx * vx;
        vy2 = vy * vy;
        vxvy2 = 2.0 * vx * vy;
        v2 = vx2 + vy2;
        speed2 = v2;      // may be needed for plotting
        v215 = 1.5 * v2;
        n0 += omega * (four9ths * n * (1.0 - v215) - n0);
        nE += omega * (one9thn * (1.0 + vx3 + 4.5 * vx2 - v215) - nE);
        nW += omega * (one9thn * (1.0 - vx3 + 4.5 * vx2 - v215) - nW);
        nN += omega * (one9thn * (1.0 + vy3 + 4.5 * vy2 - v215) - nN);
        nS += omega * (one9thn * (1.0 - vy3 + 4.5 * vy2 - v215) - nS);
        nNE += omega * (one36thn * (1.0 + vx3 + vy3 + 4.5 * (v2 + vxvy2) - v215) - nNE);
		nSE += omega * (one36thn * (1.0 + vx3 - vy3 + 4.5 * (v2 - vxvy2) - v215) - nSE);
        nNW += omega * (one36thn * (1.0 - vx3 + vy3 + 4.5 * (v2 - vxvy2) - v215) - nNW);
        nSW += omega * (one36thn * (1.0 - vx3 - vy3 + 4.5 * (v2 + vxvy2) - v215) - nSW);

		return (ob.r!=0)?float4(d2.r,d2.g,d2.b,1):float4(nN, nS, nNE, 1.0);
	}
	
	float4 compute3(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		float4 ro = tex2D(_rtOutPutTex, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

		float density = ro.r;
		float xvel = ro.g;
		float yvel = ro.b;
		float speed2 = ro.a;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float omega = 1.0 / (3.0 * _Viscosity + 0.5); // reciprocal of tau, the relaxation time
        float n, one9thn, one36thn, vx, vy, vx2, vy2, vx3, vy3, vxvy2, v2, v215;

        n = n0 + nN + nS + nE + nW + nNW + nNE + nSW + nSE;
        density = n;      // macroscopic density may be needed for plotting
        one9thn = one9th * n;
        one36thn = one36th * n;
        if (n > 0)
        {
              vx = (nE + nNE + nSE - nW - nNW - nSW) / n;
        }
        else vx = 0.0;
              xvel = vx;        // may be needed for plotting
        if (n > 0)
        {
              vy = (nN + nNE + nNW - nS - nSE - nSW) / n;
        }
        else vy = 0.0;
        yvel = vy;        // may be needed for plotting
        vx3 = 3.0 * vx;
        vy3 = 3.0 * vy;
        vx2 = vx * vx;
        vy2 = vy * vy;
        vxvy2 = 2.0 * vx * vy;
        v2 = vx2 + vy2;
        speed2 = v2;      // may be needed for plotting
        v215 = 1.5 * v2;
        n0 += omega * (four9ths * n * (1.0 - v215) - n0);
        nE += omega * (one9thn * (1.0 + vx3 + 4.5 * vx2 - v215) - nE);
        nW += omega * (one9thn * (1.0 - vx3 + 4.5 * vx2 - v215) - nW);
        nN += omega * (one9thn * (1.0 + vy3 + 4.5 * vy2 - v215) - nN);
        nS += omega * (one9thn * (1.0 - vy3 + 4.5 * vy2 - v215) - nS);
        nNE += omega * (one36thn * (1.0 + vx3 + vy3 + 4.5 * (v2 + vxvy2) - v215) - nNE);
		nSE += omega * (one36thn * (1.0 + vx3 - vy3 + 4.5 * (v2 - vxvy2) - v215) - nSE);
        nNW += omega * (one36thn * (1.0 - vx3 + vy3 + 4.5 * (v2 - vxvy2) - v215) - nNW);
        nSW += omega * (one36thn * (1.0 - vx3 - vy3 + 4.5 * (v2 + vxvy2) - v215) - nSW);

		return (ob.r!=0)?float4(d3.r,d3.g,d3.b,1):float4(nSE, nNW, nSW, 1.0);
	}

	float4 compute4(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		float4 ob = tex2D(_obstaclesTex, uv);
		float4 d1 = tex2D(_Diffuse1, uv);
		float4 d2 = tex2D(_Diffuse2, uv);
		float4 d3 = tex2D(_Diffuse3, uv);
		float4 ro = tex2D(_rtOutPutTex, uv);
		
		float n0 = d1.r;
		float nE = d1.g;
		float nW = d1.b;
				 
		float nN = d2.r;
		float nS = d2.g;
		float nNE = d2.b;
				 
		float nSE = d3.r;
		float nNW = d3.g;
		float nSW = d3.b;

		float density = ro.r;
		float xvel = ro.g;
		float yvel = ro.b;
		float speed2 = ro.a;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float omega = 1.0 / (3.0 * _Viscosity + 0.5); // reciprocal of tau, the relaxation time
        float n, one9thn, one36thn, vx, vy, vx2, vy2, vx3, vy3, vxvy2, v2, v215;

        n = n0 + nN + nS + nE + nW + nNW + nNE + nSW + nSE;
        density = n;      // macroscopic density may be needed for plotting
        one9thn = one9th * n;
        one36thn = one36th * n;
        if (n > 0)
        {
              vx = (nE + nNE + nSE - nW - nNW - nSW) / n;
        }
        else vx = 0.0;
              xvel = vx;        // may be needed for plotting
        if (n > 0)
        {
              vy = (nN + nNE + nNW - nS - nSE - nSW) / n;
        }
        else vy = 0.0;
        yvel = vy;        // may be needed for plotting
        vx3 = 3.0 * vx;
        vy3 = 3.0 * vy;
        vx2 = vx * vx;
        vy2 = vy * vy;
        vxvy2 = 2.0 * vx * vy;
        v2 = vx2 + vy2;
        speed2 = v2;      // may be needed for plotting
        v215 = 1.5 * v2;
        n0 += omega * (four9ths * n * (1.0 - v215) - n0);
        nE += omega * (one9thn * (1.0 + vx3 + 4.5 * vx2 - v215) - nE);
        nW += omega * (one9thn * (1.0 - vx3 + 4.5 * vx2 - v215) - nW);
        nN += omega * (one9thn * (1.0 + vy3 + 4.5 * vy2 - v215) - nN);
        nS += omega * (one9thn * (1.0 - vy3 + 4.5 * vy2 - v215) - nS);
        nNE += omega * (one36thn * (1.0 + vx3 + vy3 + 4.5 * (v2 + vxvy2) - v215) - nNE);
		nSE += omega * (one36thn * (1.0 + vx3 - vy3 + 4.5 * (v2 - vxvy2) - v215) - nSE);
        nNW += omega * (one36thn * (1.0 - vx3 + vy3 + 4.5 * (v2 - vxvy2) - v215) - nNW);
        nSW += omega * (one36thn * (1.0 - vx3 - vy3 + 4.5 * (v2 + vxvy2) - v215) - nSW);

		return (ob.r!=0)?float4(ro.r,ro.g,ro.b,ro.a):float4(density, xvel, yvel, speed2);
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

		Pass {
			Fog { Mode Off }
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment compute4
			ENDCG
		}
		
	} 
	
	FallBack "Diffuse"
}
