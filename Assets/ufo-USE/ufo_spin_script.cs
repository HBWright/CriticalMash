using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOSpinner : MonoBehaviour
{
    [Tooltip("Degrees per second the UFO will spin")]
    public float spinSpeed = 45f;  // You can adjust this in the Inspector

    void Update()
    {
        // Rotate around the local Y axis to the left
        transform.Rotate(Vector3.forward, -spinSpeed * Time.deltaTime, Space.Self);
    }
}