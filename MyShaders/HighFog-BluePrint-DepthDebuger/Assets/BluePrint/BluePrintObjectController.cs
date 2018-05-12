using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class BluePrintObjectController : MonoBehaviour {
	
	public BluePrintCamera mC;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
//		Texture t = mC.Texture1s [0];
//		GetComponent<Renderer> ().sharedMaterial.SetTexture ("_LayerTex1", t);
	}

	public void SwithLayer(RenderTexture t, float layer)
	{
		GetComponent<Renderer> ().sharedMaterial.SetTexture ("_MainTex", t);
		GetComponent<Renderer> ().sharedMaterial.SetFloat ("_Layer", layer);
	}
}
