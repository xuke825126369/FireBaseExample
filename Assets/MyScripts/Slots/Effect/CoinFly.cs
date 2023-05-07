using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

[LuaCallCSharp]
public enum CoinFlyCount {
	Few = 6, 
	middle = 10, 
	many = 14
};


[LuaCallCSharp]
public class CoinFly : MonoBehaviour {
	public int m_coinCount;
	public float m_frameTime;
	public Sprite[] coinFlipSprites;

	public static CoinFly instance;
	private List<CoinFlip> m_coinFlipList = new List<CoinFlip>();

	void Awake () {
		instance = this;
		for (int i = 0; i < m_coinCount; i++) {
			GameObject gameObject = new GameObject ();
			RectTransform rectTransform = gameObject.AddComponent<RectTransform> ();
			gameObject.AddComponent<Image> ();
			CoinFlip coinFlip = gameObject.AddComponent<CoinFlip> ();
			rectTransform.SetParent (transform);
			m_coinFlipList.Add (coinFlip);
		}
	}

	public void Fly(Vector3 worldStart, Vector3 worldEnd, int coinFlyCount, System.Action doneAction)
	{
		int count = 0;
		for (int i = 0; i < m_coinFlipList.Count; i++) 
		{
			CoinFlip coinFlipScript = m_coinFlipList [i];
			if (!coinFlipScript.gameObject.activeInHierarchy) 
			{
				if (count >= coinFlyCount) break;
				count++;
				coinFlipScript.gameObject.SetActive(true);
				Transform coinTransform = coinFlipScript.transform;
				Vector3 controlPoint1 = new Vector3 (Random.Range (100f, 300.0f), Random.Range (0f, 100.0f), worldStart.z);
                Vector3 controlPoint2 = new Vector3(Random.Range(-100.0f, 100f), Random.Range(-100.0f, 100.0f), worldStart.z);
                Vector3 controlPoint3 = new Vector3(Random.Range(-300.0f, -100f), Random.Range(-100.0f, 0.0f), worldStart.z);

                coinTransform.localScale = Vector3.zero;
				coinTransform.transform.position = worldStart;
				
                float fDeltaTime = 0.05f * count;
				float fFlyAniTime = 1.0f;
                LeanTween.move(coinTransform.gameObject, new Vector3[]{worldStart, controlPoint1, controlPoint1, controlPoint2, controlPoint2, controlPoint3, controlPoint3, worldEnd}, fFlyAniTime).setEase(LeanTweenType.easeInOutQuad).setDelay(fDeltaTime);
				float maxScale = Random.Range (1.5f, 2.5f);
				float finalScale = 0.5f;
				LeanTween.scale (coinTransform.gameObject, Vector3.one * maxScale, 0.5f).setDelay(fDeltaTime);
				LeanTween.scale (coinTransform.gameObject, Vector3.one * finalScale, 0.5f).setDelay(fDeltaTime + 0.5f);
				LeanTween.delayedCall (fFlyAniTime + fDeltaTime, () => {
					coinFlipScript.gameObject.SetActive(false);
				});
			}
		}

		LeanTween.delayedCall (1.0f , () => {
			doneAction();
		});
	}

	public void Clear() {
		for (int i = 0; i < m_coinFlipList.Count; i++) {
			CoinFlip coinFlipScript = m_coinFlipList [i];
			coinFlipScript.gameObject.SetActive(false);
		}
	}
}
