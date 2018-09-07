using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum EffectEnum
{
    BaseEffect,
    BSCEffect,
}

[ExecuteInEditMode]
public class RenderImage : MonoBehaviour {

    //public static RenderImage Instance;

    public BaseEffect curEffect;

    [Header("----后处理效果----")]
    public BaseEffect baseEffect = new BaseEffect();
    public BSCEffect bscEffect = new BSCEffect();


    void Start()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            enabled = false;
            return;
        }

        ChangeEffect(EffectEnum.BSCEffect);

    }

    public void ChangeEffect(EffectEnum effect)
    {
        switch(effect)
        {
            case EffectEnum.BaseEffect:
                curEffect = baseEffect;
                break;
            case EffectEnum.BSCEffect:
                curEffect = bscEffect;
                break;
        }

        if(curEffect == null)
        {
            return;
        }
        curEffect.Start();

        if (!curEffect.isShaderSupported())
        {
            enabled = false;
        }


    }

    public void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curEffect != null)
        {
            curEffect.Update(sourceTexture, destTexture);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }


    void OnDisable()
    {
        if (curEffect != null)
        {
            curEffect.End();
        }
    }

}
