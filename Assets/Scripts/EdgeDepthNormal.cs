using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class EdgeDepthNormal : BaseEffect
{
    [Range(0.0f, 1.0f)]
    public float edgeOnly = 1.0f;//背景颜色显示程度(1为只显示边缘)、

    public Color edgeColor = Color.black;//边框颜色

    public Color backgroundColor = Color.white;  //只显示边缘时的背景颜色

    public float normalSensitivity = 1.0f;//法线灵敏度

    public float depthSensitivity = 1.0f;//深度灵敏度
  
    public float sampleDistanceple = 1.0f;//采样距离

    public EdgeDepthNormal() : base()
    {

    }

    public override void Start()
    {
        RenderImage.mainCamera.depthTextureMode |= DepthTextureMode.DepthNormals;
        Init("ShaderLab_Study/EdgeDepthNormal");
    }

    public override void Update(RenderTexture sourceTex, RenderTexture renderTex)
    {
        if (m_Shader != null)
        {
            m_Material.SetFloat("_EdgeOnly", edgeOnly);
            m_Material.SetColor("_EdgeColor", edgeColor);
            m_Material.SetColor("_BackgroundColor", backgroundColor);
            m_Material.SetFloat("_NormalSensitivity", normalSensitivity);
            m_Material.SetFloat("_DepthSensitivity", depthSensitivity);
            m_Material.SetFloat("_SampleDistance", sampleDistanceple);

            Graphics.Blit(sourceTex, renderTex, m_Material);
        }
        else
        {
            Graphics.Blit(sourceTex, renderTex);
        }
    }
}
