using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Collections;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;

public class ButtonManager : MonoBehaviour
{
    private Queue<int> buttonQueue = new Queue<int>();
    public TextMeshProUGUI task;
    private int maxSize = 3;

    // Preset sequences
    private readonly int[][] sequences =
    {
        new int[] { 9, 13, 3 },
        new int[] { 5, 9, 5 },
        new int[] { 10, 15, 7 }
    };

    private int currentSequenceIndex = 0;

    public bool sequence1 = false;
    public bool sequence2 = false;
    public bool sequence3 = false;
    public bool isActive = false; // if false, you can't attempt to match the sequence
    public GameObject checkOBJ;
    public AudioSource ding;
    private GameManager gm;

    private void Awake()
    {
        gm = FindObjectOfType<GameManager>();
    }
    public void Update()
    {
        if (!isActive) return;

        if (sequence1 == false)
        {
            task.text = "Activate\nShields";
        }
        else if (sequence2 == false)
        {
            task.text = "Initialize\nCannons";
        }
        else if (sequence3 == false)
        {
            task.text = "Fire\nCannons";
        }
        else
        {
            task.text = "COMPLETE\n";
        }
    }

    public void RegisterButtonPress(int buttonID)
    {
        if (!isActive) return; // ignore presses until activated

        buttonQueue.Enqueue(buttonID);

        if (buttonQueue.Count > maxSize)
            buttonQueue.Dequeue();

        Debug.Log("Current sequence: " + string.Join(", ", buttonQueue));

        CheckSequence();
    }

    public void CheckPress(int buttonID)
    {
        if (!isActive) return;
        
        buttonQueue.Enqueue(buttonID);

        if (buttonQueue.Count > maxSize)
            buttonQueue.Dequeue();

        Debug.Log("Current sequence: " + string.Join(", ", buttonQueue));

        CheckSequence();
    }

    private void CheckSequence()
    {
        if (buttonQueue.Count < maxSize) return; // only checks when full

        int[] currentQueue = buttonQueue.ToArray();

        // Compares current target sequence
        if (currentQueue.SequenceEqual(sequences[currentSequenceIndex]))
        {
            Debug.Log($"Matched sequence {currentSequenceIndex + 1}!");

            StartCoroutine(Checkmark());

            switch (currentSequenceIndex)
            {
                case 0: sequence1 = true; break;
                case 1: sequence2 = true; break;
                case 2: sequence3 = true; break;
            }

            // Advance to next sequence
            if (currentSequenceIndex < sequences.Length - 1)
                currentSequenceIndex++;
            else
            {
                Debug.Log("All sequences matched!");
                gm.GameWon();
            }
        }
    }

    public int[] GetSequence()
    {
        return buttonQueue.ToArray();
    }

    private IEnumerator Checkmark()
    {
        checkOBJ.SetActive(true);
        ding.Play();
        yield return new WaitWhile(() => ding.isPlaying);
        checkOBJ.SetActive(false);
    }
}