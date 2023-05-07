using System.Collections;
using System.Collections.Generic;
using UnityEngine;

struct ParticleData {
	public Vector3 startPos;
	public Vector3 controlPos;
	public float startSize;
	public float time;
}

public class ParticleAttractor: MonoBehaviour {
	public static ParticleAttractor instance;

	private int m_uniqueID = 0;
	private ParticleSystem m_particleSystem;
	private ParticleSystem.Particle[] m_particles;
	private List<Vector4> m_customData = new List<Vector4>();
	private Dictionary<int, ParticleData> m_dict = new Dictionary<int, ParticleData>();

	public Vector3 m_targetPos;
	public float m_speed = 5f;
	public float m_finalSize;

	// Use this for initialization
	void Start () {
		m_particleSystem = GetComponent<ParticleSystem>();
		m_particles = new ParticleSystem.Particle[m_particleSystem.main.maxParticles];
		instance = this;
	}

	// Update is called once per frame
	void LateUpdate()
	{
		if (!m_particleSystem.isPlaying)
			return;
		int num = m_particleSystem.GetParticles(m_particles);
		m_particleSystem.GetCustomParticleData(m_customData, ParticleSystemCustomData.Custom1);

		for (int i = 0; i < num; i++)
		{
			if (m_customData[i].x == 0.0f)
			{
				m_customData[i] = new Vector4(++m_uniqueID, 0, 0, 0);
			}
			int id = (int)m_customData[i].x;
			if (!m_dict.ContainsKey(id))
			{
				if (m_particles[i].position.y < -1500)
				{
					ParticleData particleData = new ParticleData();
					particleData.startPos = m_particles[i].position;
					particleData.startSize = m_particles[i].startSize;
					if (m_particles[i].position.x < 0)
					{
						particleData.controlPos = new Vector3(m_particles[i].position.x - 100, 0, m_particles[i].position.z);
					}
					else
					{
						particleData.controlPos = new Vector3(m_particles[i].position.x + 100, 0, m_particles[i].position.z);
					}
					particleData.time = 0;
					m_dict[id] = particleData;
				}
			}
			else
			{
				float distance = Vector3.Distance(m_targetPos, m_dict[id].startPos);
				float totalTime = distance / m_speed;
				ParticleData particleData = m_dict[id];
				particleData.time += Time.deltaTime;
				m_dict[id] = particleData;
				float t = m_dict[id].time / totalTime;
				m_particles[i].position = Bezier(m_dict[id].startPos, m_dict[id].controlPos, m_targetPos, t);
				m_particles[i].startSize = Mathf.Lerp(m_dict[id].startSize, m_finalSize, (t - 0.8f) / 0.2f);
				if (t > 1)
				{
					m_particles[i].remainingLifetime = 0;
				}
			}
		}
		m_particleSystem.SetParticles(m_particles, num);
		m_particleSystem.SetCustomParticleData(m_customData, ParticleSystemCustomData.Custom1);
	}

	public void Play(Vector3 pos, Vector3 targetPos) 
	{
		m_particleSystem.Clear();
		m_dict.Clear ();
		m_customData.Clear ();
		transform.position = pos;
		m_targetPos = targetPos;
		m_particleSystem.Play ();
	}

	private Vector3 Bezier(Vector3 p0, Vector3 p1, Vector3 p2, float t)
	{
		t = Mathf.Clamp01(t);
		return (1 - t) * (1 - t) * p0 + 2 * t * (1 - t) * p1 + t * t * p2;

	}

}
