using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using System.IO;

public class UICameraImageEffect : MonoBehaviour
{
    public UnityEngine.UI.RawImage image = null;
    public Camera uiCamera = null;
    static RenderTexture photoGraphTex = null;
    RenderTexture photoTargetTex = null;
    static Texture2D savePhotoGraphTex = null;

    bool isTakePhoto = false;

    CommandBuffer takePhotoCmdBuffer;

    private void Awake()
    {
        isTakePhoto = false;
        uiCamera.depthTextureMode = DepthTextureMode.None;
        uiCamera.useOcclusionCulling = false;
        uiCamera.allowMSAA = false;
        uiCamera.allowHDR = false;

        if (photoGraphTex == null)
        {
            photoGraphTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            photoGraphTex.name = "photoGraphTex";
            photoGraphTex.Create();
            photoGraphTex.wrapMode = TextureWrapMode.Clamp;
        }

        takePhotoCmdBuffer = new CommandBuffer();
        takePhotoCmdBuffer.name = "TakePhotoCmdBuffer";
        takePhotoCmdBuffer.SetRenderTarget(uiCamera.targetTexture);
        takePhotoCmdBuffer.Blit(null, photoGraphTex);
        uiCamera.AddCommandBuffer(CameraEvent.AfterImageEffects, takePhotoCmdBuffer);

    }

    //private void OnPostRender()
    //{
    //    if (isTakePhoto)
    //    {
    //        if (photoGraphTex == null)
    //        {
    //            photoGraphTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
    //            photoGraphTex.name = "photoGraphTex";
    //            photoGraphTex.Create();
    //            photoGraphTex.wrapMode = TextureWrapMode.Clamp;
    //        }

    //        Graphics.SetRenderTarget(photoGraphTex);
    //        GL.Clear(false, true, Color.white);
    //        Graphics.SetRenderTarget(null);

    //        Graphics.Blit(null, photoGraphTex);
    //        //SavePhoto();
    //        isTakePhoto = false;
    //        image.texture = photoGraphTex;
    //    }
    //}

#if UNITY_EDITOR
    [MenuItem("Editor/SavePhoto")]
    public static void SavePhotoInEditor()
    {
        string imageName = "photoGraphTex.jpg";

        if (savePhotoGraphTex == null)
        {
            savePhotoGraphTex = new Texture2D(Screen.width, Screen.height);
            savePhotoGraphTex.name = "savePhotoGraphTex";
        }

        Graphics.SetRenderTarget(photoGraphTex);
        savePhotoGraphTex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
        savePhotoGraphTex.Apply();
        Graphics.SetRenderTarget(null);

        byte[] rawData = savePhotoGraphTex.EncodeToJPG();
        File.WriteAllBytes(Application.dataPath + "/" + imageName, rawData);
        AssetDatabase.Refresh();

    }
#endif

    public void QuitTakePhoto()
    {
        image.gameObject.SetActive(false);
    }

    public void TakePhoto()
    {
        if (photoTargetTex == null)
        {
            photoTargetTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            photoTargetTex.name = "photoTargetTex";
            photoTargetTex.Create();
            photoTargetTex.wrapMode = TextureWrapMode.Clamp;
        }

        Graphics.Blit(photoGraphTex, photoTargetTex);

        image.texture = photoTargetTex;
        image.gameObject.SetActive(true);
        isTakePhoto = true;
    }

    public void SavePhoto()
    {
        string imageName = "photoGraphTex.jpg";

        if (savePhotoGraphTex == null)
        {
            savePhotoGraphTex = new Texture2D(Screen.width, Screen.height);
            savePhotoGraphTex.name = "savePhotoGraphTex";
        }

        Graphics.SetRenderTarget(photoGraphTex);
        savePhotoGraphTex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
        savePhotoGraphTex.Apply();
        Graphics.SetRenderTarget(null);

        byte[] rawData = savePhotoGraphTex.EncodeToJPG();
        File.WriteAllBytes(Application.persistentDataPath + "/" + imageName, rawData);
    }
}
