using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CoinFlip : MonoBehaviour {

	private Image m_coinImage;
	private int m_index;
	private WaitForSeconds m_waitForFrame;
	// Use this for initialization
	void Start () {
		m_index = Random.Range(0, CoinFly.instance.coinFlipSprites.Length);
		m_waitForFrame = new WaitForSeconds (CoinFly.instance.m_frameTime);
		m_coinImage = GetComponent<Image> ();
		gameObject.SetActive (false);
//		StartCoroutine(FlipAnimation());
	}
		
	void OnEnable()
	{
		if (m_coinImage == null) {
			return;
		}
		StartCoroutine(FlipAnimation());
	}

	IEnumerator FlipAnimation()
	{
		while (gameObject.activeInHierarchy) 
		{
			m_coinImage.sprite = CoinFly.instance.coinFlipSprites[m_index % CoinFly.instance.coinFlipSprites.Length];
			yield return m_waitForFrame;
			m_index++;
		}
	}
}
