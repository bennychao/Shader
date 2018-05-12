using UnityEngine;
using System.Collections;
using System.Collections.Generic;
[ExecuteInEditMode]
public class BluePrintCamera : MonoBehaviour {


	public List<RenderTexture> Texture1s = new List<RenderTexture>();
	// Use this for initialization
	void Start () {
		//GetComponent<Camera>().SetTarget
		var rtW= Screen.width/1;
		var rtH= Screen.height/1;
		RenderBuffer[] buffers = new RenderBuffer[4];
		Texture1s.Clear ();
		for (int i = 0; i < 4; i++) {
			Texture1s.Add(RenderTexture.GetTemporary (rtW, rtH, 24, RenderTextureFormat.Default));
			buffers [i] = Texture1s[i].colorBuffer;
		}


		GetComponent<Camera> ().SetTargetBuffers (buffers, Texture1s [0].depthBuffer);

		//Graphics.SetRenderTarget(buffers, Textures [0].depthBuffer);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
