using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class PhysicsButton : MonoBehaviour
{
    [Header("Button Settings")]
    public int buttonID;   

    public Rigidbody buttonTopRigid;
    public Transform buttonTop;
    public Transform buttonLowerLimit;
    public Transform buttonUpperLimit;
    public float threshHold;
    public float force = 10;
    private float upperLowerDiff;
    public bool isPressed;
    private bool prevPressedState;
    public AudioSource pressedSound;
    public Collider[] CollidersToIgnore;
    public UnityEvent onPressed;
    public UnityEvent onReleased;

    void Start()
    {
        Collider localCollider = GetComponent<Collider>();
        if (localCollider != null)
        {
            Physics.IgnoreCollision(localCollider, buttonTop.GetComponentInChildren<Collider>());

            foreach (Collider singleCollider in CollidersToIgnore)
            {
                Physics.IgnoreCollision(localCollider, singleCollider);
            }
        }
        
        if (transform.eulerAngles != Vector3.zero){
            Vector3 savedAngle = transform.eulerAngles;
            transform.eulerAngles = Vector3.zero;
            upperLowerDiff = buttonUpperLimit.position.y - buttonLowerLimit.position.y;
            transform.eulerAngles = savedAngle;
        }
        else
            upperLowerDiff = buttonUpperLimit.position.y - buttonLowerLimit.position.y;
    }

    void Update()
    {
        buttonTop.transform.localPosition = new Vector3(0, buttonTop.transform.localPosition.y, 0);
        buttonTop.transform.localEulerAngles = new Vector3(0, 0, 0);

        if (buttonTop.localPosition.y >= 0)
            buttonTop.transform.position = buttonUpperLimit.position;
        else
            buttonTopRigid.AddForce(buttonTop.transform.up * force * Time.deltaTime);

        if (buttonTop.localPosition.y <= buttonLowerLimit.localPosition.y)
            buttonTop.transform.position = buttonLowerLimit.position;

        if (Vector3.Distance(buttonTop.position, buttonLowerLimit.position) < upperLowerDiff * threshHold)
            isPressed = true;
        else
            isPressed = false;

        if (isPressed && prevPressedState != isPressed)
            Pressed();
        if (!isPressed && prevPressedState != isPressed)
            Released();
    }

    void Pressed()
    {
        prevPressedState = isPressed;
        if (pressedSound != null)
        {
            pressedSound.pitch = 1;
            pressedSound.Play();
        }

        // Find the ButtonManager and register press
        ButtonManager manager = FindObjectOfType<ButtonManager>();
        if (manager != null)
            manager.CheckPress(buttonID);

        onPressed.Invoke();
    }

    void Released()
    {
        prevPressedState = isPressed;
        onReleased.Invoke();
    }
}