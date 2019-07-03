using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class EdgeDetectionEffect : BaseEffect
{
    [Range(0.0f, 1.0f)]
    public float edgeOnly = 1.0f;//背景颜色显示程度(1为只显示边缘)、

    public Color edgeColor = Color.black;//边框颜色

    public Color backgroundColor = Color.white;  //只显示边缘时的背景颜色

    public EdgeDetectionEffect():base()
    {

    }

    public override void Start()
    {
        Init("ShaderLab_Study/EdgeDetection");
    }

    public override void Update(RenderTexture sourceTex, RenderTexture renderTex)
    {
        if (m_Shader != null)
        {
            m_Material.SetFloat("_EdgeOnly", edgeOnly);
            m_Material.SetColor("_EdgeColor", edgeColor);
            m_Material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(sourceTex, renderTex, m_Material);
        }
        else
        {
            Graphics.Blit(sourceTex, renderTex);
        }
    }
}
