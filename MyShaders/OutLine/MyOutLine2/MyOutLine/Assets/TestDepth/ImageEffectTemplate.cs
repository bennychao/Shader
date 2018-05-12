using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.ImageEffects;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/Image Effect Addtive")]
public class ImageEffectTemplate : PostEffectsBase {

	public enum Resolution
	{
		Low = 0,
		High = 1,
	}

	Resolution resolution = Resolution.Low;

	private Material innerMaterial = null;

	public Shader mainShader = null;

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

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		//Camera.main.ScreenPointToRay ();
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}
		  
		int divider = resolution == Resolution.Low ? 4 : 2;

		var rtW= source.width/divider;
		var rtH= source.height/divider;
		   
		// downsample
		RenderTexture rt = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
		rt.filterMode = FilterMode.Bilinear;
		//Graphics.Blit (source, destination, innerMaterial, 0);

		//innerMaterial.SetTexture ("_FrontMainTex", mVolumeCamera.RTS[0]);
		//innerMaterial.SetTexture ("_BackMainTex",  mVolumeCamera.RTS[1]);
		//innerMaterial.SetColor ("_FogColor", mFogColor);
		//innerMaterial.SetFloat("_VolumeFactor", mVolumeCamera.GetComponent<Camera>().farClipPlane);

		Graphics.Blit (source, destination, innerMaterial, 0);

		RenderTexture.ReleaseTemporary (rt);
	}
}
