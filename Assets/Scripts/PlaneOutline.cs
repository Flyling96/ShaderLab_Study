using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class PlaneOutline : MonoBehaviour
{
    Mesh mesh = null;
    List<Vector3> vertices = new List<Vector3>();
    List<int> vertexCounts = new List<int>();
    List<int> triangles = new List<int>();
    List<Vector3> centerVertices = new List<Vector3>();
    List<Vector4> neighborDirs = new List<Vector4>();

    public InputField addInputFieldX;
    public InputField addInputFieldY;
    //public InputField addInputFieldZ;

    private void Start()
    {
        mesh = new Mesh();
        vertices.Clear();
        triangles.Clear();
        centerVertices.Clear();
        neighborDirs.Clear();
        vertexCounts.Clear();
    }

    public void AddQuad()
    {
        int x = int.Parse(addInputFieldX.text);
        int y = int.Parse(addInputFieldY.text);
        //int z = int.Parse(addInputFieldZ.text);
        AddQuad(x, y);
        CacuEdge();
        BuildMesh();
    }


    public void BuildMesh()
    {
        mesh.vertices = vertices.ToArray();
        mesh.triangles = triangles.ToArray();
        mesh.tangents = neighborDirs.ToArray();
        GetComponent<MeshFilter>().sharedMesh = mesh;
    }

    void AddQuad(int x,int y,int z = 0)
    {
        Vector3 v0 = new Vector3(x, y, z);
        if(vertices.Contains(v0))
        {
            return;
        }
        Vector3 v1 = new Vector3(-0.5f, 0.5f, 0) + v0;
        Vector3 v2 = new Vector3(0, 0.5f, 0) + v0;
        Vector3 v3 = new Vector3(0.5f, 0.5f, 0) + v0;
        Vector3 v4 = new Vector3(0.5f, 0, 0) + v0;
        Vector3 v5 = new Vector3(0.5f, -0.5f, 0) + v0;
        Vector3 v6 = new Vector3(0, -0.5f, 0) + v0;
        Vector3 v7 = new Vector3(-0.5f, -0.5f, 0) + v0;
        Vector3 v8 = new Vector3(-0.5f, 0, 0) + v0;

        int t0 = GetVertexIndex(v0,true);
        int t1 = GetVertexIndex(v1);
        int t2 = GetVertexIndex(v2);
        int t3 = GetVertexIndex(v3);
        int t4 = GetVertexIndex(v4);
        int t5 = GetVertexIndex(v5);
        int t6 = GetVertexIndex(v6);
        int t7 = GetVertexIndex(v7);
        int t8 = GetVertexIndex(v8);

        triangles.Add(t0);
        triangles.Add(t1);
        triangles.Add(t2);
        triangles.Add(t0);
        triangles.Add(t2);
        triangles.Add(t3);
        triangles.Add(t0);
        triangles.Add(t3);
        triangles.Add(t4);
        triangles.Add(t0);
        triangles.Add(t4);
        triangles.Add(t5);
        triangles.Add(t0);
        triangles.Add(t5);
        triangles.Add(t6);
        triangles.Add(t0);
        triangles.Add(t6);
        triangles.Add(t7);
        triangles.Add(t0);
        triangles.Add(t7);
        triangles.Add(t8);
        triangles.Add(t0);
        triangles.Add(t8);
        triangles.Add(t1);
    }

    void CacuEdge()
    {
        neighborDirs.Clear();
        for(int i=0;i< vertices.Count;i++)
        {
            if (vertexCounts[i] == 4)
            {
                neighborDirs.Add(Vector4.one);
            }
            else
            {
                neighborDirs.Add(Vector4.zero);
            }
        }

        for(int i=0;i<vertices.Count;i++)
        {
            if(centerVertices.Contains(vertices[i]))
            {
                neighborDirs[i] = Vector4.one;
                if(centerVertices.Contains(vertices[i] + new Vector3(0,1,0)))
                {
                    neighborDirs[vertices.IndexOf(vertices[i] + new Vector3(0, 0.5f, 0))] = Vector4.one;
                }
                
                if(centerVertices.Contains(vertices[i] + new Vector3(1, 0, 0)))
                {
                    neighborDirs[vertices.IndexOf(vertices[i] + new Vector3(0.5f, 0, 0))] = Vector4.one;
                }
            }
        }
    }

    int GetVertexIndex(Vector3 v1, bool isCenter = false)
    {
        if(isCenter)
        {
            centerVertices.Add(v1);
        }

        int t1 = vertices.Count;
        if (vertices.Contains(v1))
        {
            t1 = vertices.IndexOf(v1);
            vertexCounts[t1]++; 
        }
        else
        {
            vertices.Add(v1);
            vertexCounts.Add(1);
        }

        return t1;
    }


}
