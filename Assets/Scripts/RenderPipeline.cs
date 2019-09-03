using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class RenderPipeline : MonoBehaviour
{
    public static RenderPipeline instance;

    public Camera shadowCamera;

    public Shader shadowDepthShader;
    public Material commonMat;

    RenderTexture shadowDepthRT;
    CommandBuffer shadowCommand;

    private void Awake()
    {
        instance = this;
        InitShadow();
    }

    void InitShadow()
    {
        shadowDepthRT = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        shadowDepthRT.name = "ShadowDepth";
    }

    void DrawShadowDepth()
    {
        //Graphics.SetRenderTarget(shadowDepthRT);
        //GL.Clear(true, true, Color.black);
        //Graphics.SetRenderTarget(null);

        //GL.PushMatrix();
        //GL.modelview = shadowCamera.worldToCameraMatrix;
        //GL.LoadProjectionMatrix(shadowCamera.projectionMatrix);

        shadowCamera.targetTexture = shadowDepthRT;
        shadowCamera.clearFlags = CameraClearFlags.SolidColor;
        shadowCamera.SetReplacementShader(shadowDepthShader, "RenderType");

        //GL.PopMatrix();

        commonMat.SetTexture("_ShadowDepthTex", shadowDepthRT);
        //Shader.SetGlobalTexture(Shader.PropertyToID("_ShadowDepthTex"), shadowDepthRT);
        Matrix4x4 shadowView = Matrix4x4.identity;
        ViewMatrix(shadowCamera, ref shadowView);

        Matrix4x4 shadowProj = GL.GetGPUProjectionMatrix(shadowCamera.projectionMatrix, true);

        //Shader.SetGlobalMatrix(Shader.PropertyToID("_ShadowCameraView"), shadowView);
        //Shader.SetGlobalMatrix(Shader.PropertyToID("_ShadowCameraProj"), shadowProj);

        Shader.SetGlobalMatrix(Shader.PropertyToID("_ShadowCameraView"), shadowCamera.worldToCameraMatrix);
        Shader.SetGlobalMatrix(Shader.PropertyToID("_ShadowCameraProj"), shadowCamera.projectionMatrix);

    }

    public static void ViewMatrix(Camera cam,ref Matrix4x4 view)
    {
        Vector3 right = cam.transform.TransformDirection(Vector3.right);
        Vector3 up = cam.transform.TransformDirection(Vector3.up);
        Vector3 forward = cam.transform.TransformDirection(Vector3.forward);
        Vector3 pos;
        pos.x = Vector3.Dot(right, cam.transform.position);
        pos.y = Vector3.Dot(up, cam.transform.position);
        pos.z = Vector3.Dot(forward, cam.transform.position);

        view.m00 = right.x; view.m10 = up.x;    view.m20 = forward.x;   view.m30 = 0.0f;
        view.m01 = right.y; view.m11 = up.y;    view.m21 = forward.y;   view.m31 = 0.0f;
        view.m02 = right.z; view.m12 = up.z;    view.m22 = forward.z;   view.m32 = 0.0f;
        view.m03 = -pos.x;  view.m13 = -pos.y;  view.m23 = -pos.z;      view.m33 = 1.0f;
    }

    private void OnPreCull()
    {
        DrawShadowDepth();
    }


}
