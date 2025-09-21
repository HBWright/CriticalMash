using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOSpinner : MonoBehaviour
{
    [Tooltip("Degrees per second the UFO will spin")]
    public float spinSpeed = 45f;

    [Tooltip("Particle system for charging/explosion effect")]
    public ParticleSystem ufoParticles;

    private float elapsedTime = 0f;
    private bool particlesTriggered = false;

    void Update()
    {
        // Spin UFO
        transform.Rotate(Vector3.forward, -spinSpeed * Time.deltaTime, Space.Self);

        // Track time
        elapsedTime += Time.deltaTime;

        // Trigger particle system at 45s
        if (!particlesTriggered && elapsedTime >= 45f)
        {
            particlesTriggered = true;
            if (ufoParticles != null)
                ufoParticles.Play();
        }
    }
}