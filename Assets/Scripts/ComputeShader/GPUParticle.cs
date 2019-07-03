using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUParticle : MonoBehaviour
{

    private struct Particle
    {
        public Vector3 position;
        public Vector3 velocity;
    }

    public int particleCount;

    public ComputeShader GPUParticleShader;

    public Material GPUParticleMat;

    const int threadCoundInGroup = 256;

    int threadGroupX = 0;

    int CSKernel = 0;

    ComputeBuffer particleBuffer;

    private void Start()
    {
        if (particleCount <= 0)
            particleCount = 1;

        threadGroupX = Mathf.CeilToInt((float)particleCount / threadCoundInGroup);
        particleBuffer = new ComputeBuffer(particleCount, sizeof(float) * 6);

        Particle[] particleArray = new Particle[particleCount];
        for (int i = 0; i < particleCount; ++i)
        {
            particleArray[i].position.x = Random.value * 2 - 1.0f;
            particleArray[i].position.y = Random.value * 2 - 1.0f;
            particleArray[i].position.z = 0;

            particleArray[i].velocity.x = 0;
            particleArray[i].velocity.y = 0;
            particleArray[i].velocity.z = 0;
        }

        particleBuffer.SetData(particleArray);

        CSKernel = GPUParticleShader.FindKernel("CSMain");

        GPUParticleShader.SetBuffer(CSKernel, "particleBuffer", particleBuffer);
        GPUParticleMat.SetBuffer("particleBuffer", particleBuffer);

    }

    private void Update()
    {
        Vector3 mousePosition = GetMousePosition();
        float[] mousePosition2D = { mousePosition.x, mousePosition.y };

        GPUParticleShader.SetInt("isChangeVelocity", Input.GetMouseButton(0)?1:-1);

        GPUParticleShader.SetFloat("deltaTime", Time.deltaTime);
        GPUParticleShader.SetFloats("mousePosition", mousePosition2D);

        GPUParticleShader.Dispatch(CSKernel, threadGroupX, 1, 1);
    }

    private void OnRenderObject()
    {
        GPUParticleMat.SetPass(0);

        Graphics.DrawProcedural(MeshTopology.Points, 1, particleCount);
    }

    void OnDestroy()
    {
        if (particleBuffer != null)
            particleBuffer.Release();
    }

    private Vector3 GetMousePosition()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit = new RaycastHit();
        if (Physics.Raycast(ray, out hit))
            return hit.point;
        return Vector3.zero;
    }



}
