using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class UICameraImageEffect : MonoBehaviour
{
    static RenderTexture photoGraphTex = null;
    static Texture2D savePhotoGraphTex = null;

    private void Awake()
    {
        if (photoGraphTex == null)
        {
            photoGraphTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            photoGraphTex.name = "photoGraphTex";
            photoGraphTex.Create();
            photoGraphTex.wrapMode = TextureWrapMode.Clamp;
        }
    }

    private void OnPostRender()
    {
        Graphics.Blit(null, photoGraphTex);
    }

    [MenuItem("Editor/SavePhoto")]
    public static void SavePhoto()
    {
        string imageName = "photoGraphTex.jpg";

        if (savePhotoGraphTex == null)
        {
            savePhotoGraphTex = new Texture2D(Screen.width, Screen.height);
            savePhotoGraphTex.name = "savePhotoGraphTex";
        }

        RenderTexture.active = photoGraphTex;
        savePhotoGraphTex.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
        savePhotoGraphTex.Apply();

        byte[] rawData = savePhotoGraphTex.EncodeToJPG();
        File.WriteAllBytes(Application.dataPath + "/" + imageName, rawData);
        AssetDatabase.Refresh();

    }
}
