using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class AnimateHandInput : MonoBehaviour
{
    public Animator handAnim;
    public InputActionProperty pinchAnim;
    public InputActionProperty gripAnim;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float triggerValue = pinchAnim.action.ReadValue<float>();
        handAnim.SetFloat("Trigger", triggerValue);

        float gripValue = gripAnim.action.ReadValue<float>();
        handAnim.SetFloat("Grip", gripValue);
    }
}
