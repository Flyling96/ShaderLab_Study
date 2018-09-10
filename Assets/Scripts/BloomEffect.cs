﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class BloomEffect : BaseEffect
{


    [Range(0, 4)]
    public int iterations = 3;//高斯模糊的迭代次数

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;//迭代中_BlurSize变化的间隔

    [Range(1, 8)]
    public int downSample = 2;//降采样的程度

    [Range(0.0f, 4.0f)]
    public float brightThreshold = 0.6f;

    public BloomEffect():base()
    {

    }

    public override void Start()
    {
        Init("ShaderLab_Study/BloomEffect");
    }

    public override void Update(RenderTexture sourceTex, RenderTexture renderTex)
    {
        if (m_Shader != null)
        {
            m_Material.SetFloat("_BrightThreshold", brightThreshold);
            //降采样
            int renderTexWidth = sourceTex.width / downSample;
            int renderTexHeight = sourceTex.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(renderTexWidth, renderTexHeight, 0);
            //采用双线性过滤
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(sourceTex, buffer0, m_Material, 0);

            for (int i = 0; i < iterations; i++)
            {
                m_Material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(renderTexWidth, renderTexHeight, 0);
                Graphics.Blit(buffer0, buffer1, m_Material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(renderTexWidth, renderTexHeight, 0);

                Graphics.Blit(buffer0, buffer1, m_Material, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            m_Material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(sourceTex, renderTex, m_Material,3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(sourceTex, renderTex);
        }
    }
}
