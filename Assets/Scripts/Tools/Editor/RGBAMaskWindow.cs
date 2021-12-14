using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class RGBAMaskWindow : EditorWindow
{
    [MenuItem("Tools/EncodePicture/RGBAMask")]
    public static void OpenWindow()
    {
        RGBAMaskWindow window = (RGBAMaskWindow)EditorWindow.GetWindow<RGBAMaskWindow>("Encode Picture");
        window.position = new Rect(500, 500, 500, 500);
        window.Show();
    }

    public Texture m_RGBA;
    public Texture m_Mask;

    private RenderTexture m_RGBAPreview;
    private RenderTexture m_MaskPreview;
    private RenderTexture m_ResultPreview;

    private Shader m_Shader;
    private Material m_Material;

    private void OnEnable()
    {
        m_RGBAPreview = RenderTexture.GetTemporary(512, 512);
        m_MaskPreview = RenderTexture.GetTemporary(512, 512);
        m_ResultPreview = RenderTexture.GetTemporary(512, 512);

        m_Shader = Shader.Find("Unlit/TexPreview");
        if(m_Shader != null)
        {
            m_Material = new Material(m_Shader);
        }
    }

    private void OnDisable()
    {
        RenderTexture.ReleaseTemporary(m_RGBAPreview);
        RenderTexture.ReleaseTemporary(m_MaskPreview);
        RenderTexture.ReleaseTemporary(m_ResultPreview);
    }

    private void OnGUI()
    {
        m_Refresh = false;
        EditorGUILayout.BeginHorizontal();

        DrawTexture(180, ref m_RGBA, m_RGBAPreview);

        DrawTexture(180, ref m_Mask, m_MaskPreview);

        EditorGUILayout.EndHorizontal();

        GUILayout.FlexibleSpace();
        var rect = EditorGUILayout.GetControlRect(GUILayout.MaxWidth(m_ResultPreview.width),
            GUILayout.MaxHeight(m_ResultPreview.height));
        float w = rect.width;
        float h = rect.height;
        rect.height = Mathf.Min(rect.height, m_ResultPreview.height * rect.width / m_ResultPreview.width);
        rect.width = Mathf.Min(rect.width, m_ResultPreview.width * rect.height / m_ResultPreview.height);
        rect.x += (w - rect.width) * 0.5f;
        rect.y += (h - rect.height) * 0.5f;
        EditorGUI.DrawTextureTransparent(rect, m_ResultPreview);
        GUILayout.FlexibleSpace();

        if (m_Refresh)
        {
            m_Material.SetTexture("_Source", m_RGBA);
            m_Material.SetTexture("_Mask", m_Mask);
            m_Material.SetInt("_Encode", 1);

            Graphics.Blit(null, m_ResultPreview, m_Material, 0);
        }

        if(GUILayout.Button("Save"))
        {
            var path = AssetDatabase.GetAssetPath(m_RGBA);
            var name = Path.GetFileNameWithoutExtension(path) + "_Encode";
            path = Path.GetDirectoryName(path);
            path = EditorUtility.SaveFilePanelInProject("Save", name, "png", "", path);
            if(!string.IsNullOrEmpty(path))
            {
                RenderTexture old = RenderTexture.active;
                var rt = m_ResultPreview;
                RenderTexture.active = rt;
                Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
                png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
                byte[] bytes = png.EncodeToPNG();

                FileStream file = File.Open(path, FileMode.Create);
                BinaryWriter writer = new BinaryWriter(file);
                writer.Write(bytes);
                file.Close();
                Texture2D.DestroyImmediate(png);
                png = null;
                RenderTexture.active = old;
                //AssetDatabase.ImportAsset(path);

                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                importer.textureType = TextureImporterType.Sprite;
                AssetDatabase.ImportAsset(path);
            }
        }


    }

    private bool m_Refresh = false;

    private void DrawTexture(float width, ref Texture target, RenderTexture rt)
    {
        EditorGUILayout.BeginVertical(GUILayout.MaxWidth(width));

        EditorGUI.BeginChangeCheck();
        target = (Texture)EditorGUILayout.ObjectField(target, typeof(Texture), false,GUILayout.Width(width));

        var rect = EditorGUILayout.GetControlRect(GUILayout.Width(width), GUILayout.Height(width));
        EditorGUI.DrawTextureTransparent(rect, rt);

        if(EditorGUI.EndChangeCheck())
        {
            m_Refresh = true;
            m_Material.SetTexture("_Source", target);
            m_Material.SetInt("_Encode", 0);

            Graphics.Blit(null, rt, m_Material, 0);
        }

        EditorGUILayout.EndVertical();
    }


}
