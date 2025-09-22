using UnityEngine;
using UnityEngine.UI;
using TMPro;

[System.Serializable]
public class PageData
{
    public string sequenceText;
    public Sprite sequenceImage;
}

public class Manual : MonoBehaviour
{
    [Header("UI References")]
    public TextMeshPro sequenceTextUI; 
    public Image sequenceImageUI;

    [Header("Buttons")]
    public Button leftButton;
    public Button rightButton;

    [Header("Pages")]
    public PageData[] pages;

    private int currentIndex = 0;

    void Start()
    {
        leftButton.onClick.AddListener(PreviousPage);
        rightButton.onClick.AddListener(NextPage);
        UpdatePage();
    }

    void NextPage()
    {
        currentIndex = (currentIndex + 1) % pages.Length;
        UpdatePage();
    }

    void PreviousPage()
    {
        currentIndex = (currentIndex - 1 + pages.Length) % pages.Length;
        UpdatePage();
    }

    void UpdatePage()
    {
        sequenceTextUI.text = pages[currentIndex].sequenceText;
        sequenceImageUI.sprite = pages[currentIndex].sequenceImage;
    }
}