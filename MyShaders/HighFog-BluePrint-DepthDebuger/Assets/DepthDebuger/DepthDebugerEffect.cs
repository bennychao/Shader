using UnityEngine;
using UnityStandardAssets.ImageEffects;



[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/Depth Debuger")]
public class DepthDebugerEffect : PostEffectsBase {

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

		Graphics.Blit (source, destination, innerMaterial, 0);

	}
}
