Shader "Gooest/LBM/Init" {

	Properties {
		//_Diffuse1 ("Diffuse Texture 1", 2D) = "" {}
		//_Diffuse2 ("Diffuse Texture 2", 2D) = "" {}
		//_Diffuse3 ("Diffuse Texture 3", 2D) = "" {}
		_obstaclesTex ("_obstaclesTex", 2D) = "" {}
		_FlowSpeed ("_FlowSpeed", float) = 0.1
		_T ("time", float) = 0.0
	}
	
	CGINCLUDE
	
	#include "UnityCG.cginc"
	
	uniform sampler2D _Diffuse1;
	uniform sampler2D _Diffuse2;
	uniform sampler2D _Diffuse3;
	uniform sampler2D _obstaclesTex;
	uniform float _FlowSpeed;
	uniform float _T;

	

	float4 compute1 (v2f_img IN) : SV_Target {
		float2 uv = IN.uv;
		

		//float4 v1 = tex2D(_Diffuse1, uv);
		//float4 v2 = tex2D(_Diffuse2, uv);
		//float4 v3 = tex2D(_Diffuse3, uv);
		
		//float n0 = v1.r;
		//float nE = v1.g;
		//float nW = v1.b;
				 
		//float nN = v2.r;
		//float nS = v2.g;
		//float nNE = v2.b;
				 
		//float nSE = v3.r;
		//float nNW = v3.g;
		//float nSW = v3.b;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float v=_FlowSpeed;

		float n0 = four9ths * (1.0 - 1.5 * v * v);
        float nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
        float nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
	
		n0 = clamp(n0, 0.0, 1.0);
		nE = clamp(nE, 0.0, 1.0);
		nW = clamp(nW, 0.0, 1.0);
		
		float4 ob = tex2D(_obstaclesTex, uv);
		return (ob.r>=0.9)?float4(1,0,0,1):float4(n0, nE, nW, 1.0);
	}
	
	float4 compute2(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float v=_FlowSpeed;

		float nN = one9th * (1.0 - 1.5 * v * v);
        float nS = one9th * (1.0 - 1.5 * v * v);
        float nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);

		nN = clamp(nN, 0.0, 1.0);
		nS = clamp(nS, 0.0, 1.0);
		nNE = clamp(nNE, 0.0, 1.0);
		
		float4 ob = tex2D(_obstaclesTex, uv);
		return (ob.r>=0.9)?float4(0,0,0,1):float4(nN, nS, nNE, 1.0);
	}
	
	float4 compute3(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		float v=_FlowSpeed;

		float nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
        float nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
        float nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);

		nSE = clamp(nSE, 0.0, 1.0);
		nNW = clamp(nNW, 0.0, 1.0);
		nSW = clamp(nSW, 0.0, 1.0);
		
		float4 ob = tex2D(_obstaclesTex, uv);
		return (ob.r>=0.9)?float4(0,0,0,1):float4(nSE, nNW, nSW, 1.0);
	}

	float4 compute4(v2f_img IN) : SV_Target {
		float2 uv = IN.uv;

		float v=_FlowSpeed;

		float density = 1.0;
        float xvel = v;
        float yvel = 0;
        float speed2 = v * v;
		
		float4 ob = tex2D(_obstaclesTex, uv);
		return (ob.r>=0.9)?float4(0,0,0,1):float4(density, xvel, yvel, speed2);
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
