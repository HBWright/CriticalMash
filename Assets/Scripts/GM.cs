using UnityEngine;
using TMPro;

public class TimerDisplay : MonoBehaviour
{
    public TextMeshProUGUI timerText; 
    public float timeRemaining = 60f; // start time
    public bool countDown = true;     
    private bool timerRunning = true;

    void Update()
    {
        if (!timerRunning) return;

        if (countDown) // ngl chat wrote this timer its 2am bro
        {
            timeRemaining -= Time.deltaTime;
            if (timeRemaining <= 0)
            {
                timeRemaining = 0;
                timerRunning = false;
            }
        }
        else
        {
            timeRemaining += Time.deltaTime;
        }

        // seconds.milliseconds
        int seconds = Mathf.FloorToInt(timeRemaining);
        int milliseconds = Mathf.FloorToInt((timeRemaining - seconds) * 1000);

        timerText.text = $"{seconds:00}.{milliseconds:000}";
    }
}