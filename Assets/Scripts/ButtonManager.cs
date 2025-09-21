using System.Collections.Generic;
using UnityEngine;

public class ButtonManager : MonoBehaviour
{
    private Queue<int> buttonQueue = new Queue<int>();
    private int maxSize = 3;

    public void RegisterButtonPress(int buttonID)
    {
        buttonQueue.Enqueue(buttonID);

        if (buttonQueue.Count > maxSize)
            buttonQueue.Dequeue();

        Debug.Log("Current sequence: " + string.Join(", ", buttonQueue));
    }

    public int[] GetSequence()
    {
        return buttonQueue.ToArray();
    }
}