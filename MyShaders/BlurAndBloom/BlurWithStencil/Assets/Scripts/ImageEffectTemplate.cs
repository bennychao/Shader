using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.ImageEffects;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/Image Effect Template")]
public class ImageEffectTemplate : PostEffectsBase {

	public enum Resolution
	{
		Low = 0,
		High = 1,
	}

	[Range(0.0f, 1.5f)]
	public float threshold = 0.25f;
	[Range(0.0f, 2.5f)]
	public float intensity = 0.75f;

	[Range(0.25f, 5.5f)]
	public float blurSize = 1.0f;

	[Range(1, 4)]
	public int blurIterations = 1;

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

		float widthMod = resolution == Resolution.Low ? 0.5f : 1.0f;
		innerMaterial.SetVector ("_Parameter", new Vector4 (blurSize * widthMod, 0.0f, threshold, intensity));
		int divider = resolution == Resolution.Low ? 4 : 2;

		var rtW= source.width/divider;
		var rtH= source.height/divider;

		// downsample
		RenderTexture rt = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
		rt.filterMode = FilterMode.Bilinear;





		Graphics.Blit (source, rt, innerMaterial, 1);

		//var passOffs= blurType == BlurType.Standard ? 0 : 2;

		for(int i = 0; i < blurIterations; i++)
		{
			innerMaterial.SetVector ("_Parameter", new Vector4 (blurSize * widthMod + (i*1.0f), 0.0f, threshold, intensity));

			// vertical blur
			RenderTexture rt2 = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
			rt2.filterMode = FilterMode.Bilinear;
			Graphics.Blit (rt, rt2, innerMaterial, 2);
			RenderTexture.ReleaseTemporary (rt);
			rt = rt2;

			// horizontal blur
			rt2 = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);
			rt2.filterMode = FilterMode.Bilinear;
			Graphics.Blit (rt, rt2, innerMaterial, 3);
			RenderTexture.ReleaseTemporary (rt);
			rt = rt2;
		}

		innerMaterial.SetTexture ("_Bloom", rt);

		Graphics.Blit (source, destination, innerMaterial, 0);


		RenderTexture.ReleaseTemporary (rt);

	}
}
