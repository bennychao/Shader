using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class VolumeCamera : MonoBehaviour {

	public MRTDebugCamera Debug;
	public RenderTexture[] RTS;
	// Use this for initialization
	void Start () {
		var rtW= Screen.width/1;
		var rtH= Screen.height/1;

		RTS = new RenderTexture[2];
		//[TODO check the format ???]
		RenderTexture RT = RenderTexture.GetTemporary (rtW, rtH, 24, RenderTextureFormat.Default);
		RenderTexture RT2 = RenderTexture.GetTemporary (rtW, rtH, 0, RenderTextureFormat.Default);	//have not depth buffer

		RTS [0] = RT;
		RTS [1] = RT2;

		RenderBuffer[] buffers = new RenderBuffer[2];
		buffers [0] = RT.colorBuffer;
		buffers [1] = RT2.colorBuffer;

		GetComponent<Camera> ().SetTargetBuffers (buffers, RT.depthBuffer);

		Debug.AddRT (RT);
		Debug.AddRT (RT2);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
