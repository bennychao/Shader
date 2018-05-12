using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;



[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/Blue Print")]
public class BluePrintEffect : PostEffectsBase {
	
	public Shader mainShader = null;
	public float _fSampleDistance = 1;
	public float _fSensitivity = 1;

	private Material innerMaterial = null;

	public override bool CheckResources ()
	{
		CheckSupport (false);

		innerMaterial = CheckShaderAndCreateMaterial (mainShader, innerMaterial);

		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;

		if (!isSupported)
			ReportAutoDisable ();
		return isSupported;
	}

	void OnDisable ()
	{
		if (innerMaterial)
			DestroyImmediate (innerMaterial);
	}
	
	// Update is called once per frame
	void Update () {
	
	}


	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		//Camera.main.ScreenPointToRay ();
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}


		RenderTexture rt1=  GetComponent<BluePrintCamera> ().Texture1s [0];


		var rtW= source.width/1;
		var rtH= source.height/1;

		//not used
		//GL.Clear (true, true, Color.black, 1.0f);

		RenderTexture layer0 = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
		layer0.filterMode = FilterMode.Bilinear;
		innerMaterial.SetFloat ("_SampleDistance", _fSampleDistance);
		innerMaterial.SetFloat ("_Sensitivity", _fSensitivity);

		Graphics.Blit (rt1, layer0, innerMaterial, 0);

		//GL.Clear (true, false, Color.black, 1.0f);
		Graphics.Blit (layer0, destination);
		RenderTexture.ReleaseTemporary (layer0);
	}
}
