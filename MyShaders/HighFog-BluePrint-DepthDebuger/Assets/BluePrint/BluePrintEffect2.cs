using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;


[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/Blue Print2")]

public class BluePrintEffect2 : PostEffectsBase {

	public GameObject BCamera;

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



		var rtW= source.width/1;
		var rtH= source.height/1;

		//not used
		//GL.Clear (true, true, Color.black, 1.0f);

		BluePrintCamera2[] rcmas = BCamera.GetComponentsInChildren<BluePrintCamera2> ();

		RenderTexture rt1 = rcmas[0].RT;
		RenderTexture rt2 = rcmas[1].RT;

		RenderTexture layer0 = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
		layer0.filterMode = FilterMode.Bilinear;
		innerMaterial.SetFloat ("_SampleDistance", _fSampleDistance);
		innerMaterial.SetFloat ("_Sensitivity", _fSensitivity);

		Graphics.Blit (rt1, layer0, innerMaterial, 0);


		RenderTexture layer1 = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
		layer0.filterMode = FilterMode.Bilinear;
		innerMaterial.SetFloat ("_SampleDistance", _fSampleDistance);
		innerMaterial.SetFloat ("_Sensitivity", _fSensitivity);
		innerMaterial.SetTexture ("_MainTex2", rt1);
		innerMaterial.SetTexture ("_MainTex3", rt2);

		Graphics.Blit (rt1, layer1, innerMaterial, 1);

		//GL.Clear (true, false, Color.black, 1.0f);
		Graphics.Blit (layer1, destination);
		RenderTexture.ReleaseTemporary (layer0);
	}
}
