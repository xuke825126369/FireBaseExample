using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoadingRotate : MonoBehaviour {
	public float speed = 360;

	// Update is called once per frame
	void Update () {
		Vector3 eulerAngles = transform.localEulerAngles;
		eulerAngles.z = eulerAngles.z + speed * Time.deltaTime;
		transform.localEulerAngles = eulerAngles;
	}
}
