using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;

public class GameManager : MonoBehaviour
{
    [Header("UI Elements")]
    public Button startButton;
    public GameObject buttonToHide;
    public GameObject starShips;
    public GameObject warpShader;
    public TextMeshProUGUI timerText;

    [Header("Timer Settings")]
    public float timeRemaining = 60f;
    public bool countDown = true;

    [Header("Sound Effects")]
    public AudioSource pregame;
    public AudioSource warpEnd;
    public AudioSource chargingSound;
    public AudioSource explosionSound;

    private bool timerRunning = false;
    private bool timerEnded = false;

    private bool reached50 = false;
    private bool reached46 = false;
    private bool playedCharging = false;

    void Start()
    {
        if (startButton != null)
            startButton.onClick.AddListener(OnStartButtonClicked);

        if (timerText != null)
            timerText.text = "";
    }

    void Update()
    {
        if (!timerRunning) return;

        if (countDown)
        {
            timeRemaining -= Time.deltaTime;

            // Trigger once when timer first reaches 50 or below
            if (!reached50 && timeRemaining <= 50f)
            {
                reached50 = true;
                OnTimerReached50();
            }

            // Trigger once when timer first reaches 46 or below
            if (!reached46 && timeRemaining <= 46f)
            {
                reached46 = true;
                OnTimerReached46();
            }

            // Trigger charging sound once at 19 seconds
            if (!playedCharging && timeRemaining <= 19f)
            {
                playedCharging = true;
                PlayChargingSound();
            }

            if (reached46)
            {
                UpdateTimerText();
            }

            if (timeRemaining <= 0)
            {
                timeRemaining = 0;
                timerRunning = false;

                if (!timerEnded)
                {
                    timerEnded = true;
                    OnTimerEnd();
                }
            }
        }
        else
        {
            timeRemaining += Time.deltaTime;
        }
    }

    private void UpdateTimerText()
    {
        int seconds = Mathf.FloorToInt(timeRemaining);
        int milliseconds = Mathf.FloorToInt((timeRemaining - seconds) * 1000);

        if (timerText != null)
            timerText.text = $"{seconds:00}.{milliseconds:000}";
    }

    private void OnStartButtonClicked()
    {
        StartCoroutine(StartSequence());
    }

    private IEnumerator StartSequence()
    {
        if (buttonToHide != null)
            buttonToHide.SetActive(false);

        pregame.Stop();
        warpEnd.Play();

        
        yield return new WaitWhile(() => warpEnd.isPlaying);

        
        warpShader.SetActive(false);
        timerRunning = true;
        timerEnded = false;
        playedCharging = false;
    }

    private void OnTimerEnd()
    {
        Debug.Log("Time finished");

        if (explosionSound != null)
            explosionSound.Play();

        // Trigger explosion animation here
    }

    private void OnTimerReached50()
    {
        if (starShips != null)
            starShips.SetActive(true);
    }

    private void OnTimerReached46()
    {
        int seconds = Mathf.FloorToInt(timeRemaining);
        int milliseconds = Mathf.FloorToInt((timeRemaining - seconds) * 1000);

        if (timerText != null)
            timerText.text = $"{seconds:00}.{milliseconds:000}";

        if (starShips != null)
            starShips.SetActive(true);
    }

    private void PlayChargingSound()
    {
        if (chargingSound != null)
            chargingSound.Play();
    }
}
