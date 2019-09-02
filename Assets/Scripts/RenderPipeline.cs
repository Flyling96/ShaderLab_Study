using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RenderPipeline : MonoBehaviour
{
    public static RenderPipeline instance;

    public Camera shadowCamera;

    RenderTexture shadowDepth;
    CommandBuffer shadowCommand;

    private void Awake()
    {
        instance = this;
    }

    void InitShadow()
    {

    }

    void OnRenderObject()
    {
        
    }
}
