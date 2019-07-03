using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class BSCEffect : BaseEffect
{
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;//亮度
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;//饱和度
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;  //对比度

    public BSCEffect():base()
    {

    }

    public override void Start()
    {
        Init("ShaderLab_Study/BSCEffect");
    }

    public override void Update(RenderTexture sourceTex, RenderTexture renderTex)
    {
        if (m_Shader != null)
        {
            m_Material.SetFloat("_Brightness", brightness);
            m_Material.SetFloat("_Saturation", saturation);
            m_Material.SetFloat("_Contrast", contrast);
            Graphics.Blit(sourceTex, renderTex, m_Material);
        }
        else
        {
            Graphics.Blit(sourceTex, renderTex);
        }
    }
}
