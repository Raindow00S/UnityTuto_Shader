using System;
using UnityEngine;

public class MatrixTest : MonoBehaviour
{
    private void Start()
    {
        var trans = this.transform;

        Debug.Log($"my local position: {trans.localPosition}");
        Debug.Log($"my position: {trans.position}");
        while (trans.parent != null)
        {
            Debug.Log($"parent local position: {trans.parent.localPosition}");
            Debug.Log($"parent position: {trans.parent.position}");
            var modelMatrix = trans.parent.localToWorldMatrix;
            Debug.Log($"calculated child position: {modelMatrix.MultiplyPoint(trans.localPosition)}");
            trans = trans.parent;
        }
    }
}