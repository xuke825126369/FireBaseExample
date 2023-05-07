using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using Spine.Unity;

public class ElementController : MonoBehaviour 
{
	public Graphic mOutAlphaGraphic;
	public Graphic mHighlightGraphic;
	public Graphic mSpineGraphic;

	private RectTransform mRectTransform;
	private Vector3[] mWorldCorners = new Vector3[4]; 
	private SkeletonGraphic mSkeletonScript = null;
	private bool mActiveAnimation = false;

	private readonly string ACTIVEANIMATION_NAME = "animation";

	// Use this for initialization
	void Start() 
	{
		mRectTransform = GetComponent<RectTransform>();
		mRectTransform.GetWorldCorners(mWorldCorners);
		if(mSpineGraphic != null)
		{
			mSkeletonScript = mSpineGraphic.GetComponent<SkeletonGraphic> ();
		}
		if(mOutAlphaGraphic != null)
		{
			Material material = Instantiate(mOutAlphaGraphic.material);
			mOutAlphaGraphic.material = material;
		}

		PlayActiveAnimation();

	//	StartCoroutine(Test());
	}

	private IEnumerator Test()
	{
		while (true) 
		{
			PlayActiveAnimation();
			yield return new WaitForSeconds(4.0f);
			StopActiveAnimation ();
			yield return new WaitForSeconds(1.0f);
		}
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (mOutAlphaGraphic != null) {
			mRectTransform.GetWorldCorners(mWorldCorners);
			mOutAlphaGraphic.material.SetFloat ("_MinX", mWorldCorners [0].x);
			mOutAlphaGraphic.material.SetFloat ("_MinY", mWorldCorners [0].y);
			mOutAlphaGraphic.material.SetFloat ("_MaxX", mWorldCorners [2].x);
			mOutAlphaGraphic.material.SetFloat ("_MaxY", mWorldCorners [2].y);
		}
	}

	public void PlayActiveAnimation()
	{
		mActiveAnimation = true;
		if (mHighlightGraphic != null) {
			StartCoroutine (BlinkHighlight ());
		}
		if (mOutAlphaGraphic != null) {
			LeanTween.value (mOutAlphaGraphic.gameObject, SetOutAlphaValue, 0.0f, 1.0f, 0.5f);
		}
		if (mSpineGraphic != null) {
			mSkeletonScript.AnimationState.TimeScale = 1.0f;
			mSkeletonScript.AnimationState.SetAnimation(0, ACTIVEANIMATION_NAME, true).TrackTime = 0.0f;
		}
	}

	public void StopActiveAnimation()
	{
		mActiveAnimation = false;
		if (mHighlightGraphic != null) {
			LeanTween.cancel(mHighlightGraphic.gameObject);
			LeanTween.alpha (mHighlightGraphic.rectTransform, 0.0f, 0.1f);
		}
		if (mOutAlphaGraphic != null) {
			LeanTween.cancel(mOutAlphaGraphic.gameObject);
			LeanTween.value (mOutAlphaGraphic.gameObject, SetOutAlphaValue, mOutAlphaGraphic.color.a, 0.0f, 0.1f);
		}
		if (mSpineGraphic != null) {
			mSkeletonScript.AnimationState.TimeScale = 0.0f;
		}
	}

	public void Reset()
	{
		if (mHighlightGraphic != null) {
			
		}
		if (mOutAlphaGraphic != null) {
			
		}
		if (mSpineGraphic != null) {
			mSkeletonScript.AnimationState.SetAnimation(0, ACTIVEANIMATION_NAME, true).TrackTime = 0.0f;
		}
	}

	private IEnumerator BlinkHighlight()
	{	
		while (mActiveAnimation) 
		{
			Color color = mHighlightGraphic.color;
			LeanTween.alpha (mHighlightGraphic.rectTransform, 1.0f, 0.3f);
			yield return new WaitForSeconds(1.0f);
			LeanTween.alpha (mHighlightGraphic.rectTransform, 0.0f, 0.1f);
			yield return new WaitForSeconds(0.3f);
		}
	}

	private void SetOutAlphaValue(float alpha)
	{
		mOutAlphaGraphic.material.SetFloat ("_alpha", alpha);
	}
}
