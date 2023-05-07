using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LightEffect : MonoBehaviour {
	private List<Image> m_lightList = new List<Image>();

	void Awake()
	{
		Image [] lightArray = GetComponentsInChildren<Image> ();
		for (int i = 0; i < lightArray.Length; i++) {
			m_lightList.Add (lightArray[i]);
		}
	}
	// Use this for initialization
	void OnEnable()
	{
		float halfPeriod = 0.5f;
		LTDescr des1 = LeanTween.value (gameObject, 0, 1, halfPeriod).setLoopPingPong (-1);
		des1.setOnUpdate ((float value) => {
			for (int i = 0; i < m_lightList.Count; i = i + 2) {
				Color c = m_lightList[i].color;
				c.a = value;
				m_lightList[i].color = c;
			}
		});

		LTDescr des2 = LeanTween.value (gameObject, 0, 1, halfPeriod).setLoopPingPong (-1).setDelay(halfPeriod);
		des2.setOnUpdate ((float value) => {
			for (int i = 1; i < m_lightList.Count; i = i + 2) {
				Color c = m_lightList[i].color;
				c.a = value;
				m_lightList[i].color = c;
			}
		});
	}

	void OnDisable()
	{
		LeanTween.cancel (gameObject);
	}
}
