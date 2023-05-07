using System;
using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

namespace AssemblyCSharp.ZTestThemeScene
{
    public class Test : MonoBehaviour
    {
        private GameObject child;
        private void Start()
        {
            child = transform.GetChild(0).gameObject;
        }

        private void Update()
        {
            child.SetActive(false);
            child.SetActive(true);
            child.SetActive(UnityEngine.Random.Range(0f, 1f) < 0.5f);
        }


        private void LateUpdate()
        {
            if (child.activeInHierarchy)
            {
                
            }
        }
    }
}
