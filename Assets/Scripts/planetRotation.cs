using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class planetRotation : MonoBehaviour
{
    private GameObject planet;
    [SerializeField] private float roatationSpeed = 5.0f;
    // Start is called before the first frame update
    void Start()
    {
        planet = this.gameObject;
    }

    // Update is called once per frame
    void Update()
    {
        if (planet != null)
        {
            planet.transform.Rotate(Vector3.up * roatationSpeed *  Time.deltaTime);
        }
    }
}
