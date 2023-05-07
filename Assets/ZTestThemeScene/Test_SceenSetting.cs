using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Test_SceenSetting : MonoBehaviour {
    [SerializeField]
    private bool orLandScape = true; 

    private const int fWidth = 1920;
    private const int fHeight = 1080;
         
    private int fActualReferenceWidth = 1920;
    private int fActualReferenceHeight = 1080;
        

    public bool bLandScape
    {
        set
        {
            orLandScape = value;
        }

        get
        {
            return orLandScape;
        }
    }

	void Start () {
		Set();
	}

	public void Set()
    {
        if (!bLandScape)
        {

            float fRatio = Screen.width / (float)Screen.height;
            float fCameraHeigh = 1005.0f * 2 * 1080.0f / 1920.0f / fRatio;
            Camera.main.orthographicSize = fCameraHeigh / 2.0f;
        }

        Debug.Log("分辨率：" + Screen.width + " | " + Screen.height);
    }
	
	// Update is called once per frame
	void Update () {
        Set();
	}
}
