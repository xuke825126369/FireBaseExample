using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

public class Test : MonoBehaviour
{
    void Start()
    {
        LeanTween.moveLocalY(gameObject, 50f, 0.5f).setDelay(2).setLoopPingPong(-1);
        transform.SetAsLastSibling();

        TextMeshProUGUI mText = null;
    }
}
