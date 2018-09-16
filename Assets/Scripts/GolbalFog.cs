using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GolbalFog : BaseEffect
{

    public Color fogColor = new Color(1, 1, 1, 1);

    public float fogStart;

    public float fogEnd;

    public float fogDensity;

    public GolbalFog() : base()
    {

    }

    public override void Start()
    {
        RenderImage.mainCamera.depthTextureMode |= DepthTextureMode.Depth;
        Init("ShaderLab_Study/GolbalFog");
    }

    public override void Update(RenderTexture sourceTex, RenderTexture renderTex)
    {
        if (RenderImage.mainCamera == null)
            return;
        if (m_Shader != null)
        {
            Camera camera = RenderImage.mainCamera;
            float fov = camera.fieldOfView;
            float near = camera.nearClipPlane;
            float far = camera.farClipPlane;
            float aspect = camera.aspect;//视锥体截面宽高比

            float halfHeight = near * Mathf.Atan(fov / 2 * Mathf.Deg2Rad);
            Vector3 nearRight = camera.transform.right * halfHeight * aspect;
            Vector3 nearTop = camera.transform.up * halfHeight;

            //在TL射线上，TL向量模/near = 像素到摄像机的距离/像素的深度值
            //像素到摄像机的向量的模 = 深度值 * TL向量模/near

            Vector3 topRight = camera.transform.forward * near + nearRight + nearTop;
            float scale = topRight.magnitude / near;

            topRight.Normalize();
            topRight *= scale;

            Vector3 topLeft = camera.transform.forward * near - nearRight + nearTop;
            topLeft.Normalize();
            topLeft *= scale;

            Vector3 bottomLeft = camera.transform.forward * near - nearRight - nearTop;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = camera.transform.forward * near + nearRight - nearTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            Matrix4x4 sceenVertexRayMat = Matrix4x4.identity;

            sceenVertexRayMat.SetRow(0, bottomLeft);
            sceenVertexRayMat.SetRow(1, bottomRight);
            sceenVertexRayMat.SetRow(2, topRight);
            sceenVertexRayMat.SetRow(3, topLeft);

            m_Material.SetMatrix("_SceenVertexRayMat", sceenVertexRayMat);
            m_Material.SetFloat("_FogStart", fogStart);
            m_Material.SetFloat("_FogEnd", fogEnd);
            m_Material.SetFloat("_FogDensity", fogDensity);
            m_Material.SetColor("_FogColor", fogColor);

            Graphics.Blit(sourceTex, renderTex,m_Material);

        }
        else
        {
            Graphics.Blit(sourceTex, renderTex);
        }
    }
}
