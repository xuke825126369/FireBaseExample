using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(ParticleSystemRenderer))]
public class ParticleBound : MonoBehaviour {
	public RectTransform m_boundingRectTransform;
	public Material m_originalMaterial;

	Material m_material;
	Vector3[] m_worldCornors = new Vector3[4];
	int m_boundPropertyId;
	// Use this for initialization
	void Start () {
		m_boundPropertyId = Shader.PropertyToID ("_Bound");
		ParticleSystemRenderer render = GetComponent<ParticleSystemRenderer> ();
		m_material = new Material(m_originalMaterial);
		render.material = m_material;
		SetBounding ();
	}

	public void SetBounding()
	{
		if (m_boundingRectTransform != null) {
			m_boundingRectTransform.GetWorldCorners(m_worldCornors);
			Vector4 v = new Vector4 (m_worldCornors[0].x, m_worldCornors[0].y, m_worldCornors[2].x, m_worldCornors[2].y);
			m_material.SetVector(m_boundPropertyId, v);
		}
	}
		
	void Update () {
		SetBounding ();
	}
}
