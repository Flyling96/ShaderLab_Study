﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum EffectEnum
{
    BaseEffect,
    BSCEffect,
    EdgeDetectionEffect,
    GaussianBlur,
    BloomEffect,
}

[ExecuteInEditMode]
public class RenderImage : MonoBehaviour {

    //public static RenderImage Instance;

    BaseEffect curEffect;

    EffectEnum preEffectEnum;
    public EffectEnum curEffectEnum;

    [Header("----后处理效果----")]
    public BaseEffect baseEffect = new BaseEffect();
    public BSCEffect bscEffect = new BSCEffect();
    public EdgeDetectionEffect edgeDetection = new EdgeDetectionEffect();
    public GaussianBlur gaussianBlur = new GaussianBlur();
    public BloomEffect bloomEffect = new BloomEffect();


    void Start()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            enabled = false;
            return;
        }

        preEffectEnum = EffectEnum.BSCEffect;
        curEffectEnum = EffectEnum.BSCEffect;
        ChangeEffect(EffectEnum.BSCEffect);

    }

    private void Update()
    {
        if(preEffectEnum!=curEffectEnum)
        {
            preEffectEnum = curEffectEnum;
            ChangeEffect(curEffectEnum);
        }
    }

    public void ChangeEffect(EffectEnum effect)
    {
        switch (effect)
        {
            case EffectEnum.BaseEffect:
                curEffect = baseEffect;
                break;
            case EffectEnum.BSCEffect:
                curEffect = bscEffect;
                break;
            case EffectEnum.EdgeDetectionEffect:
                curEffect = edgeDetection;
                break;
            case EffectEnum.GaussianBlur:
                curEffect = gaussianBlur;
                break;
            case EffectEnum.BloomEffect:
                curEffect = bloomEffect;
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
