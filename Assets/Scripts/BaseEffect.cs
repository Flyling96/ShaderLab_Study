using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseEffect {

    protected Shader m_Shader;
    protected Material m_Material;

    public BaseEffect()
    {
    }

    public virtual void Start()
    {
        Init("ShaderLab_Study/BaseEffect");
    }

    protected void Init(string shaderName)
    {
        m_Shader = Shader.Find(shaderName);
        m_Material = new Material(m_Shader);
        m_Material.hideFlags = HideFlags.HideAndDontSave;
    }

    public bool isShaderSupported()
    {
        return m_Shader.isSupported;
    }

    public virtual void End()
    {
        if(m_Material!=null)
        {
            GameObject.DestroyImmediate(m_Material);
            m_Material = null;
        }
    }

    public virtual void Update(RenderTexture sourceTex, RenderTexture renderTex)
    {
        if(sourceTex != null)
        {
            Graphics.Blit(sourceTex, renderTex, m_Material);
        }
    }
}
