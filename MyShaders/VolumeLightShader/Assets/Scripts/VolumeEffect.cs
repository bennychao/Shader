using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;



[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
[AddComponentMenu ("Image Effects/My Effects/Volume Effect")]
public class VolumeEffect : PostEffectsBase {

		public Shader mainShader = null;
		public float _fSampleDistance = 1;
		public float _fSensitivity = 1;
		public VolumeCamera mVolumeCamera;

	public Color mFogColor;


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

			innerMaterial.SetTexture ("_FrontMainTex", mVolumeCamera.RTS[0]);
			innerMaterial.SetTexture ("_BackMainTex",  mVolumeCamera.RTS[1]);
			innerMaterial.SetColor ("_FogColor", mFogColor);
			innerMaterial.SetFloat("_VolumeFactor", mVolumeCamera.GetComponent<Camera>().farClipPlane);
			
			Graphics.Blit (source, destination, innerMaterial, 0);

		}
	}