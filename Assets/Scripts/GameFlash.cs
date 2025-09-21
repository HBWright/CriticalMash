using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameOverScript : MonoBehaviour
{
    [SerializeField]
    private Image image;
   
    
    void Start()
    {
        StartCoroutine(FadeOut(image, 3f));
    }

    // Update is called once per frame

  
    void Update()
    {
       
        
    }
    public IEnumerator FadeOut(Image image, float timetoFade)
    {
        Color startColor = image.color;
        Color endColor = new Color(startColor.r, startColor.g, startColor.b, 0f);

        float timer = 0;
        while (timer < timetoFade) {
            timer += Time.deltaTime;
            image.color = Color.Lerp(startColor, endColor, timer);
            yield return null;


        }

        image.color = endColor;

    }
}
