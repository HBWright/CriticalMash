using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections;
using UnityEngine.SceneManagement; // <--- Needed for scene reload

public class GameManager : MonoBehaviour
{
    [Header("UI Elements")]
    public Button startButton;
    public Button restartButton; // <-- assign in inspector
    public GameObject buttonToHide;
    public GameObject starShips;
    public GameObject warpShader;
    public GameObject Environment;
    public GameObject GameOver;
    public GameObject Credits;
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

        if (restartButton != null)
            restartButton.onClick.AddListener(OnRestartButtonClicked);

        if (timerText != null)
            timerText.text = "";
    }

    void Update()
    {
        if (!timerRunning) return;

        if (countDown)
        {
            timeRemaining -= Time.deltaTime;

            if (!reached50 && timeRemaining <= 50f)
            {
                reached50 = true;
                OnTimerReached50();
            }

            if (!reached46 && timeRemaining <= 46f)
            {
                reached46 = true;
                OnTimerReached46();
            }

            if (!playedCharging && timeRemaining <= 19f)
            {
                playedCharging = true;
                PlayChargingSound();
            }

            if (reached46)
                UpdateTimerText();

            if (timeRemaining <= 0)
            {
                timeRemaining = 0;
                timerRunning = false;

                if (!timerEnded)
                {
                    timerEnded = true;
                    OnTimerEnd();
                }

                GameOver.SetActive(true);
                Environment.SetActive(false);

                if (restartButton != null)
                    restartButton.gameObject.SetActive(true);
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

        if (timeRemaining <= 10f)
            timerText.color = Color.red;
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

    private void OnRestartButtonClicked()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    private void OnTimerEnd()
    {
        Debug.Log("Time finished");

        if (explosionSound != null)
            explosionSound.Play();
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

        FindObjectOfType<ButtonManager>().isActive = true;
    }

    private void PlayChargingSound()
    {
        if (chargingSound != null)
            chargingSound.Play();
    }

    public void GameWon()
    {
        Debug.Log("WIN");

        // Example actions:
        timerRunning = false;
        starShips.SetActive(false);

        StartCoroutine(VictoryLap());
    }

    private IEnumerator VictoryLap()
    {
        //PutVictory Dialog Here
        //victory.Play();
        //yield return new WaitWhile(() => victory.isPlaying);
        warpEnd.Play();
        yield return new WaitWhile(() => warpEnd.isPlaying);
        warpShader.SetActive(true);

        Credits.SetActive(true);
    }
}