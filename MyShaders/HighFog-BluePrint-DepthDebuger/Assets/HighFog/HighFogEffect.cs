using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;



[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/High Fog")]

public class HighFogEffect : PostEffectsBase
{
	public Shader fastBloomShader = null;

	private Material innerMaterial = null;

	public Color FogColor;
	public float FogHeight = 0;

	public override bool CheckResources ()
	{
		CheckSupport (false);

		innerMaterial = CheckShaderAndCreateMaterial (fastBloomShader, innerMaterial);
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

		RenderTexture rt = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
		rt.filterMode = FilterMode.Bilinear;

		Camera cam = GetComponent<Camera> ();
		innerMaterial.SetMatrix ("_CameraTRS", Matrix4x4.TRS(Vector3.zero, cam.transform.rotation, Vector3.one));


//		_FogColor("Fog Color", Color) =  (1,1,1,1)
		innerMaterial.SetColor("_FogColor", FogColor);
		innerMaterial.SetVector ("_CameraForward", new Vector4 (transform.forward.x, transform.forward.y, transform.forward.z, 1));

		innerMaterial.SetFloat ("_FogHight", FogHeight);
//			_FogHight("Fog Hight", Float) = -1.5

		Graphics.Blit (source, destination, innerMaterial, 0);

		RenderTexture.ReleaseTemporary (rt);
	}
}
