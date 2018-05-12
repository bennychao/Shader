using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;

public class MRTDebugCamera : MonoBehaviour {


	private List<RenderTexture> mRTS = new List<RenderTexture>();

	private MRTDebugCanvas[] mImages;
	// Use this for initialization
	void Awake () {
		mImages = GetComponentsInChildren<MRTDebugCanvas> ();
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	public void AddRT(RenderTexture r){


		mImages [mRTS.Count].GetComponent<Renderer>().sharedMaterial.mainTexture = r;

		mRTS.Add (r);
	}
}
