using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LBMGPU : MonoBehaviour
{
    //plot draw type （ 0 for speed, 1 for vx, 2 for vy, 3 for curl, 4 for density)
    public enum Plot
    {
        speed = 0,
        vx = 1,
        vy = 2,
        curl = 3,
        density = 4
    }
    public int m_width=256, m_height=64;
    public float FlowSpeed = 0.1f;
    public float Viscosity = 0.02f;
    public float Contrast = 5f;
    public Plot PlotType = Plot.speed;

    private Vector2 m_obstaclePos = new Vector2(0.5f, 0.5f);   //默认障碍的摆放位置
    private float m_obstacleRadius = 0.1f;                     //默认障碍的半径大小
    private Vector2 m_inverseSize;

    [SerializeField] Shader obstaclesShader;
    [SerializeField] Shader initShader;
    [SerializeField] Shader collideShader;
    [SerializeField] Shader streamShader;
    [SerializeField] Shader stepShader;
    [SerializeField] Shader bounceShader;
    [SerializeField] Shader paintShader;
    [SerializeField] Shader copyShader; 

    Material obstaclesMat;  
    Material initMat;
    Material collideMat;
    Material streamMat;
    Material bounceMat;
    Material stepMat;
    Material paintMat;
    Material copyMat;

    RenderTexture m_obstaclesTex;
    RenderTexture rt1;
    RenderTexture rt2;
    RenderTexture rt3;
    RenderTexture rt1c;
    RenderTexture rt2c;
    RenderTexture rt3c;
    RenderTexture rtOutPutTex;
    RenderTexture rtOutPutTexc;

    void Start()
    {
        m_inverseSize = new Vector2(1.0f / m_width, 1.0f / m_height);
        
        SetupRTs();
        SetupMats();

        obstaclesMat.SetVector("_Point", m_obstaclePos);
        Graphics.Blit(null, m_obstaclesTex, obstaclesMat);

        Graphics.Blit(null, rt1, initMat,0);
        Graphics.Blit(null, rt2, initMat,1);
        Graphics.Blit(null, rt3, initMat,2);
        Graphics.Blit(null, rtOutPutTex, initMat, 3);
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Vector2 mousePos = Input.mousePosition;
            m_obstaclePos = new Vector2(mousePos.x / Screen.width, mousePos.y / Screen.height);
        }

        obstaclesMat.SetVector("_Point", m_obstaclePos);
        Graphics.Blit(null, m_obstaclesTex, obstaclesMat);

        //Graphics.Blit(null, rt1, initMat, 0);
        //Graphics.Blit(null, rt2, initMat, 1);
        //Graphics.Blit(null, rt3, initMat, 2);
        //Graphics.Blit(null, rtOutPutTex, initMat, 3);

        //把compMat的计算结果放进rt1c (compMat的输入为rt1)
        Graphics.Blit(null, rt1c, collideMat, 0);
        Graphics.Blit(null, rt2c, collideMat, 1);
        Graphics.Blit(null, rt3c, collideMat, 2);
        Graphics.Blit(null, rtOutPutTexc, collideMat, 3);

        //把copyMat计算结果放入rt1 (copyMat的输入为rt1c)
        Graphics.Blit(null, rt1, copyMat, 0);
        Graphics.Blit(null, rt2, copyMat, 1);
        Graphics.Blit(null, rt3, copyMat, 2);
        Graphics.Blit(null, rtOutPutTex, copyMat, 3);

        //把streamMat计算结果放入rt1c (streamMat的输入为rt1)
        Graphics.Blit(null, rt1c, streamMat, 0);
        Graphics.Blit(null, rt2c, streamMat, 1);
        Graphics.Blit(null, rt3c, streamMat, 2);

        ////把copyMat计算结果放入rt1 (copyMat的输入为rt1c)
        //Graphics.Blit(null, rt1, copyMat, 0);
        //Graphics.Blit(null, rt2, copyMat, 1);
        //Graphics.Blit(null, rt3, copyMat, 2);

        ////把bounceMat计算结果放入rt1 (bounceMat的输入为rt1c)
        //Graphics.Blit(null, rt1c, stepMat, 0);
        //Graphics.Blit(null, rt2c, stepMat, 1);
        //Graphics.Blit(null, rt3c, stepMat, 2);

        //把bounceMat计算结果放入rt1 (bounceMat的输入为rt1c)
        Graphics.Blit(null, rt1, bounceMat, 0);
        Graphics.Blit(null, rt2, bounceMat, 1);
        Graphics.Blit(null, rt3, bounceMat, 2);

        //
        Graphics.Blit(null, rtOutPutTex, paintMat, 0);

        stepMat.SetFloat("_T", Time.timeSinceLevelLoad);
    }

    void SetupRTs()
    {
        m_obstaclesTex = CreateRenderTexture(m_width,m_height);
        rt1 = CreateRenderTexture(m_width, m_height);
        rt2 = CreateRenderTexture(m_width, m_height);
        rt3 = CreateRenderTexture(m_width, m_height);
        rtOutPutTex = CreateRenderTexture(m_width, m_height);

        rt1c = CreateRenderTexture(m_width, m_height);
        rt2c = CreateRenderTexture(m_width, m_height);
        rt3c = CreateRenderTexture(m_width, m_height);
        rtOutPutTexc = CreateRenderTexture(m_width, m_height);
    }

    void SetupMats()
    {
        obstaclesMat = new Material(obstaclesShader);
        initMat = new Material(initShader);
        collideMat = new Material(collideShader);
        copyMat = new Material(copyShader);
        streamMat = new Material(streamShader);
        bounceMat = new Material(bounceShader);
        stepMat = new Material(stepShader);
        paintMat = new Material(paintShader);

        initMat.SetFloat("_FlowSpeed", FlowSpeed);
        initMat.SetTexture("_obstaclesTex", m_obstaclesTex);

        obstaclesMat.SetVector("_InverseSize", m_inverseSize);
        obstaclesMat.SetVector("_Point", m_obstaclePos);
        obstaclesMat.SetFloat("_Radius", m_obstacleRadius);
        
        collideMat.SetTexture("_Diffuse1", rt1);
        collideMat.SetTexture("_Diffuse2", rt2);
        collideMat.SetTexture("_Diffuse3", rt3);
        collideMat.SetTexture("_obstaclesTex", m_obstaclesTex);
        collideMat.SetTexture("rtOutPutTex", rtOutPutTex);
        collideMat.SetFloat("_Viscosity", Viscosity);

        copyMat.SetTexture("_Diffuse1", rt1c);
        copyMat.SetTexture("_Diffuse2", rt2c);
        copyMat.SetTexture("_Diffuse3", rt3c);
        copyMat.SetTexture("_rtOutPutTex", rtOutPutTexc);

        streamMat.SetTexture("_Diffuse1", rt1);
        streamMat.SetTexture("_Diffuse2", rt2);
        streamMat.SetTexture("_Diffuse3", rt3);
        streamMat.SetTexture("_obstaclesTex", m_obstaclesTex);
        streamMat.SetFloat("_FlowSpeed", FlowSpeed);
        streamMat.SetVector("_InverseSize", m_inverseSize);

        stepMat.SetTexture("_Diffuse1", rt1);
        stepMat.SetTexture("_Diffuse2", rt2);
        stepMat.SetTexture("_Diffuse3", rt3);
        stepMat.SetVector("_InverseSize", m_inverseSize);
        stepMat.SetFloat("_T", Time.timeSinceLevelLoad);

        bounceMat.SetTexture("_Diffuse1", rt1c);
        bounceMat.SetTexture("_Diffuse2", rt2c);
        bounceMat.SetTexture("_Diffuse3", rt3c);
        bounceMat.SetTexture("_obstaclesTex", m_obstaclesTex);
        bounceMat.SetVector("_InverseSize", m_inverseSize);

        paintMat.SetTexture("_Diffuse1", rt1);
        paintMat.SetTexture("_Diffuse2", rt2);
        paintMat.SetTexture("_Diffuse3", rt3);
        paintMat.SetTexture("_obstaclesTex", m_obstaclesTex);
        paintMat.SetVector("_InverseSize", m_inverseSize);
    }

    RenderTexture CreateRenderTexture(int width, int height)
    {
        RenderTexture rt = new RenderTexture(width, height, 0);
        rt.format = RenderTextureFormat.ARGBFloat;
        rt.wrapMode = TextureWrapMode.Repeat;
        rt.filterMode = FilterMode.Point;
        rt.Create();
        return rt;
    }

    void OnGUI()
    {
        Vector2 size = new Vector2(m_width, m_height) * 2;
        Vector2 space = new Vector2(3, 3);
        Rect r00 = new Rect(size.x * 0 + space.x * 1, size.y * 0 + space.y * 1, size.x, size.y);
        Rect r01 = new Rect(size.x * 0 + space.x * 1, size.y * 1 + space.y * 2, size.x, size.y);
        Rect r02 = new Rect(size.x * 0 + space.x * 1, size.y * 2 + space.y * 3, size.x, size.y);

        Rect r10 = new Rect(size.x * 1 + space.x * 2, size.y * 0 + space.y * 1, size.x, size.y);
        Rect r11 = new Rect(size.x * 1 + space.x * 2, size.y * 1 + space.y * 2, size.x, size.y);
        Rect r12 = new Rect(size.x * 1 + space.x * 2, size.y * 2 + space.y * 3, size.x, size.y);

        Rect r20 = new Rect(size.x * 2 + space.x * 3, size.y * 0 + space.y * 1, size.x, size.y);
        Rect r21 = new Rect(size.x * 2 + space.x * 3, size.y * 1 + space.y * 2, size.x, size.y);
        Rect r22 = new Rect(size.x * 2 + space.x * 3, size.y * 2 + space.y * 3, size.x, size.y);

        GUI.DrawTexture(r00, m_obstaclesTex);
        GUI.Label(r00, "  m_obstaclesTex");
        GUI.DrawTexture(r01, rtOutPutTex);
        GUI.Label(r01, "  rtOutPut");
        GUI.DrawTexture(r02, rtOutPutTexc);
        GUI.Label(r02, "  rtOutPutc");

        GUI.DrawTexture(r10, rt1);
        GUI.Label(r10, "  rt1");
        GUI.DrawTexture(r11, rt2);
        GUI.Label(r11, "  rt2");
        GUI.DrawTexture(r12, rt3);
        GUI.Label(r12, "  rt3");

        GUI.DrawTexture(r20, rt1c);
        GUI.Label(r20, "  rt1c");
        GUI.DrawTexture(r21, rt2c);
        GUI.Label(r21, "  rt2c");
        GUI.DrawTexture(r22, rt3c);
        GUI.Label(r22, "  rt3c");
    }





}
