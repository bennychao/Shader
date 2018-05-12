using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class BluePrintCamera2 : MonoBehaviour {

	public RenderTexture RT;
	public BluePrintCamera2 PreCamera;
	public BluePrintObjectController Obj;
	public float Layer = 0;
	// Use this for initialization
	void Start () {
		var rtW= Screen.width/1;
		var rtH= Screen.height/1;

		RT = RenderTexture.GetTemporary (rtW, rtH, 24, RenderTextureFormat.Default);

		GetComponent<Camera> ().SetTargetBuffers (RT.colorBuffer, RT.depthBuffer);

	}
	
	// Update is called once per frame
	void Update () {
	
	}


	void OnPreRender(){
		//change the shader's mode
		RenderTexture r = PreCamera != null ? PreCamera.RT :RT;

		Obj.SwithLayer(r, Layer);
	}
}
