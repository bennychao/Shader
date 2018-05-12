using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class TestShow : MonoBehaviour {

	public BluePrintCamera2 PreCamera;
	public int index = 0;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		GetComponent<Renderer>().sharedMaterial.mainTexture = PreCamera.RT;
	}
}
