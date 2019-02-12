Shader "Gooest/LBM/stream" {

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

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		// first start in NW corner...
		//for (int x = 0; x < xdim - 1; x++)
		//{
		//    for (int y = ydim - 1; y > 0; y--)
		//    {
		//if (x >= 0 && x < xdim - 1 && y > 0 && y <= ydim - 1)
		if (x >= 0 && x <(1.0-_InverseSize.x) && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			//uint pos = x + xdim * y;
			nN =tex2D(_Diffuse2, float2(x,y-_InverseSize.y)).r;						//_directionBuffer[x + xdim * (y - 1)].nN; //nN[x, y] = nN[x, y - 1];        // move the north-moving particles
			nNW = tex2D(_Diffuse3, float2(x+_InverseSize.x,y-_InverseSize.y)).g;	//_directionBuffer[(x + 1) + xdim * (y - 1)].nNW; //nNW[x, y] = nNW[x + 1, y - 1];  // and the northwest-moving particles
		}
		//    }
		//}
        
		// now start in NE corner...
		//for (int x = xdim - 1; x > 0; x--)
		//{
		//for (int y = ydim - 1; y > 0; y--)
		//if (x > 0 && x <= xdim - 1 && y > 0 && y <= ydim - 1)
		//if (x > 0 && x <= 1.0-_InverseSize.x && y > 0 && y <= 1.0-_InverseSize.y)
		if (x > _InverseSize.x && x <= 1.0-_InverseSize.x && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			//uint pos = x + xdim * y;
			nE = tex2D(_Diffuse1, float2(x-_InverseSize.x,y)).g;					//_directionBuffer[(x - 1) + xdim * y].nE; // move the east-moving particles
			nNE = tex2D(_Diffuse2, float2(x-_InverseSize.x,y-_InverseSize.y)).b;	//_directionBuffer[(x - 1) + xdim * (y - 1)].nNE; // and the northeast-moving particles
		}
		//}

			// now start in SE corner...
		//for (int x = xdim - 1; x > 0; x--)
		//{
		//for (int y = 0; y < ydim - 1; y++)
		//if (x > 0 && x <= xdim - 1 && y >= 0 && y < ydim - 1)
		//if (x > 0 && x <= 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		if (x > _InverseSize.x && x <= 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			//uint pos = x + xdim * y;
			nS = tex2D(_Diffuse2, float2(x,y+_InverseSize.y)).g;					//_directionBuffer[x + xdim * (y + 1)].nS; // move the south-moving particles
			nSE = tex2D(_Diffuse3, float2(x-_InverseSize.x,y+_InverseSize.y)).r;	//_directionBuffer[(x - 1) + xdim * (y + 1)].nSE; // and the southeast-moving particles
		}
		//}

		// now start in the SW corner...
		//for (int x = 0; x < xdim - 1; x++)
		//{
		//for (int y = 0; y < ydim - 1; y++)
		if (x >= 0 && x < 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			//uint pos = x + xdim * y;
			nW = tex2D(_Diffuse1, float2(x+_InverseSize.x,y)).b;					//_directionBuffer[(x + 1) + xdim * y].nW; // move the west-moving particles
			nSW = tex2D(_Diffuse3, float2(x+_InverseSize.x,y+_InverseSize.y)).b;	//_directionBuffer[(x + 1) + xdim * (y + 1)].nSW; // and the southwest-moving particles
		}
		//}
    
		// We missed a few at the left and right edges:
		//for (int y = 0; y < ydim - 1; y++)
		//if (x == 0 && y >= 0 && y < ydim - 1)
		//if (x == 0 && y >= 0 && y < 1.0-_InverseSize.y)
		if (x <=_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nS =tex2D(_Diffuse2, float2(x,y+_InverseSize.y)).g;  // _directionBuffer[0 + xdim * (y + 1)].nS;
		}
		//for (int y = ydim - 1; y > 0; y--)
		//if (x == (xdim - 1) && y > 0 && y <= ydim - 1)
		//if (x == 1.0-_InverseSize.x && y > 0 && y <= 1.0-_InverseSize.y)
		if (x >= 1.0-_InverseSize.x && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nN = tex2D(_Diffuse2, float2(x,y-_InverseSize.y)).r;  //_directionBuffer[(xdim - 1) + xdim * (y - 1)].nN;
		}

		// Now handle left boundary as in Pullan's example code:
		// Stream particles in from the non-existent space to the left, with the
		// user-determined speed:
		float v = _FlowSpeed;
		//for (int y = 0; y < ydim; y++)
		//if (x == 0 && y >= 0 && y < ydim)
		//if (x == 0 && y >= 0 && y < 1.0)
		if (x <= _InverseSize.x && y >= 0 && y < 1.0)
		{
			//if (_barrierBuffer[0 + xdim * y] == 0)
			if (ob.r == 0)
			{
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
			}
		}
    
		// Try the same thing at the right edge and see if it works:
		//for (int y = 0; y < ydim; y++)
		//if (x == (xdim - 1) && y >= 0 && y < ydim)
		//if (x == 1.0-_InverseSize.x && y >= 0 && y < 1.0)
		if (x >= 1.0-_InverseSize.x && y >= 0 && y < 1.0)
		{
			//if (_barrierBuffer[0 + xdim * y] == 0)
			if (ob.r == 0)
			{
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}
		}
    
		// Now handle top and bottom edges:
		//for (int x = 0; x < xdim; x++)
		//if (x >= 0 && x < xdim && (y == 0 || y == (ydim - 1)))
		//if (x >= 0 && x < 1.0 && (y == 0 || y == 1.0-_InverseSize.y))
		if (x >= 0 && x < 1.0 && (y <=_InverseSize.y || y >= 1.0-_InverseSize.y))
		{
			//uint pos1 = x + xdim * 0;
			//uint pos2 = x + xdim * (ydim - 1);
			//if(y==0){
			if(y <=_InverseSize.y){
				n0 = four9ths * (1.0 - 1.5 * v * v);
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nN = one9th * (1.0 - 1.5 * v * v);
				nS = one9th * (1.0 - 1.5 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}

			//if(y==1.0-_InverseSize.y){
			if(y>=1.0-_InverseSize.y){
				n0 = four9ths * (1.0 - 1.5 * v * v);
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nN = one9th * (1.0 - 1.5 * v * v);
				nS = one9th * (1.0 - 1.5 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}
		}
              
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

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		// first start in NW corner...
		if (x >= 0 && x <(1.0-_InverseSize.x) && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nN =tex2D(_Diffuse2, float2(x,y-_InverseSize.y)).r;						//_directionBuffer[x + xdim * (y - 1)].nN; //nN[x, y] = nN[x, y - 1];        // move the north-moving particles
			nNW = tex2D(_Diffuse3, float2(x+_InverseSize.x,y-_InverseSize.y)).g;	//_directionBuffer[(x + 1) + xdim * (y - 1)].nNW; //nNW[x, y] = nNW[x + 1, y - 1];  // and the northwest-moving particles
		}
        
		// now start in NE corner...
		if (x > _InverseSize.x && x <= 1.0-_InverseSize.x && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nE = tex2D(_Diffuse1, float2(x-_InverseSize.x,y)).g;					//_directionBuffer[(x - 1) + xdim * y].nE; // move the east-moving particles
			nNE = tex2D(_Diffuse2, float2(x-_InverseSize.x,y-_InverseSize.y)).b;	//_directionBuffer[(x - 1) + xdim * (y - 1)].nNE; // and the northeast-moving particles
		}

		// now start in SE corner...
		if (x > _InverseSize.x && x <= 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nS = tex2D(_Diffuse2, float2(x,y+_InverseSize.y)).g;					//_directionBuffer[x + xdim * (y + 1)].nS; // move the south-moving particles
			nSE = tex2D(_Diffuse3, float2(x-_InverseSize.x,y+_InverseSize.y)).r;	//_directionBuffer[(x - 1) + xdim * (y + 1)].nSE; // and the southeast-moving particles
		}

		// now start in the SW corner...
		if (x >= 0 && x < 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nW = tex2D(_Diffuse1, float2(x+_InverseSize.x,y)).b;					//_directionBuffer[(x + 1) + xdim * y].nW; // move the west-moving particles
			nSW = tex2D(_Diffuse3, float2(x+_InverseSize.x,y+_InverseSize.y)).b;	//_directionBuffer[(x + 1) + xdim * (y + 1)].nSW; // and the southwest-moving particles
		}
    
		// We missed a few at the left and right edges:
		if (x <=_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nS =tex2D(_Diffuse2, float2(x,y+_InverseSize.y)).g;  // _directionBuffer[0 + xdim * (y + 1)].nS;
		}
		if (x >= 1.0-_InverseSize.x && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nN = tex2D(_Diffuse2, float2(x,y-_InverseSize.y)).r;  //_directionBuffer[(xdim - 1) + xdim * (y - 1)].nN;
		}

		// Now handle left boundary as in Pullan's example code:
		// Stream particles in from the non-existent space to the left, with the
		// user-determined speed:
		float v = _FlowSpeed;
		if (x <= _InverseSize.x && y >= 0 && y < 1.0)
		{
			if (ob.r == 0)
			{
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
			}
		}
    
		// Try the same thing at the right edge and see if it works:
		if (x >= 1.0-_InverseSize.x && y >= 0 && y < 1.0)
		{
			if (ob.r == 0)
			{
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}
		}
    
		// Now handle top and bottom edges:
		if (x >= 0 && x < 1.0 && (y <=_InverseSize.y || y >= 1.0-_InverseSize.y))
		{
			//if(y==0){
			if(y <=_InverseSize.y){
				n0 = four9ths * (1.0 - 1.5 * v * v);
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nN = one9th * (1.0 - 1.5 * v * v);
				nS = one9th * (1.0 - 1.5 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}

			//if(y==1.0-_InverseSize.y){
			if(y>=1.0-_InverseSize.y){
				n0 = four9ths * (1.0 - 1.5 * v * v);
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nN = one9th * (1.0 - 1.5 * v * v);
				nS = one9th * (1.0 - 1.5 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
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

		// calculation short-cuts:
		float four9ths = 4.0 / 9;
		float one9th = 1.0 / 9;
		float one36th = 1.0 / 36;

		// first start in NW corner...
		if (x >= 0 && x <(1.0-_InverseSize.x) && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nN =tex2D(_Diffuse2, float2(x,y-_InverseSize.y)).r;						//_directionBuffer[x + xdim * (y - 1)].nN; //nN[x, y] = nN[x, y - 1];        // move the north-moving particles
			nNW = tex2D(_Diffuse3, float2(x+_InverseSize.x,y-_InverseSize.y)).g;	//_directionBuffer[(x + 1) + xdim * (y - 1)].nNW; //nNW[x, y] = nNW[x + 1, y - 1];  // and the northwest-moving particles
		}
        
		// now start in NE corner...
		if (x > _InverseSize.x && x <= 1.0-_InverseSize.x && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nE = tex2D(_Diffuse1, float2(x-_InverseSize.x,y)).g;					//_directionBuffer[(x - 1) + xdim * y].nE; // move the east-moving particles
			nNE = tex2D(_Diffuse2, float2(x-_InverseSize.x,y-_InverseSize.y)).b;	//_directionBuffer[(x - 1) + xdim * (y - 1)].nNE; // and the northeast-moving particles
		}

		// now start in SE corner...
		if (x > _InverseSize.x && x <= 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nS = tex2D(_Diffuse2, float2(x,y+_InverseSize.y)).g;					//_directionBuffer[x + xdim * (y + 1)].nS; // move the south-moving particles
			nSE = tex2D(_Diffuse3, float2(x-_InverseSize.x,y+_InverseSize.y)).r;	//_directionBuffer[(x - 1) + xdim * (y + 1)].nSE; // and the southeast-moving particles
		}

		// now start in the SW corner...
		if (x >= 0 && x < 1.0-_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nW = tex2D(_Diffuse1, float2(x+_InverseSize.x,y)).b;					//_directionBuffer[(x + 1) + xdim * y].nW; // move the west-moving particles
			nSW = tex2D(_Diffuse3, float2(x+_InverseSize.x,y+_InverseSize.y)).b;	//_directionBuffer[(x + 1) + xdim * (y + 1)].nSW; // and the southwest-moving particles
		}
    
		// We missed a few at the left and right edges:
		if (x <=_InverseSize.x && y >= 0 && y < 1.0-_InverseSize.y)
		{
			nS =tex2D(_Diffuse2, float2(x,y+_InverseSize.y)).g;  // _directionBuffer[0 + xdim * (y + 1)].nS;
		}
		if (x >= 1.0-_InverseSize.x && y > _InverseSize.y && y <= 1.0-_InverseSize.y)
		{
			nN = tex2D(_Diffuse2, float2(x,y-_InverseSize.y)).r;  //_directionBuffer[(xdim - 1) + xdim * (y - 1)].nN;
		}

		// Now handle left boundary as in Pullan's example code:
		// Stream particles in from the non-existent space to the left, with the
		// user-determined speed:
		float v = _FlowSpeed;
		if (x <= _InverseSize.x && y >= 0 && y < 1.0)
		{
			if (ob.r == 0)
			{
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
			}
		}
    
		// Try the same thing at the right edge and see if it works:
		if (x >= 1.0-_InverseSize.x && y >= 0 && y < 1.0)
		{
			if (ob.r == 0)
			{
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}
		}
    
		// Now handle top and bottom edges:
		if (x >= 0 && x < 1.0 && (y <=_InverseSize.y || y >= 1.0-_InverseSize.y))
		{
			//if(y==0){
			if(y <=_InverseSize.y){
				n0 = four9ths * (1.0 - 1.5 * v * v);
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nN = one9th * (1.0 - 1.5 * v * v);
				nS = one9th * (1.0 - 1.5 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
			}

			//if(y==1.0-_InverseSize.y){
			if(y>=1.0-_InverseSize.y){
				n0 = four9ths * (1.0 - 1.5 * v * v);
				nE = one9th * (1.0 + 3.0 * v + 3.0 * v * v);
				nW = one9th * (1.0 - 3.0 * v + 3.0 * v * v);
				nN = one9th * (1.0 - 1.5 * v * v);
				nS = one9th * (1.0 - 1.5 * v * v);
				nNE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nSE = one36th * (1.0 + 3.0 * v + 3.0 * v * v);
				nNW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
				nSW = one36th * (1.0 - 3.0 * v + 3.0 * v * v);
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
