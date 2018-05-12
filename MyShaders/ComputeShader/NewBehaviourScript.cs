using UnityEngine;
using System.Collections;

public class NewBehaviourScript : MonoBehaviour {
    private ComputeBuffer P;          //代码一切归 恬纳微晰
    public ComputeShader comshader;   //代码一切归 恬纳微晰
    int kernel;
    // Use this for initialization
    void Start () {
        P = new ComputeBuffer(3, 4); //设置P Buffer的大小,12为字节大小(float3),
        kernel = comshader.FindKernel("CSMain");//找到Main的id号

        int[] values = { 1, 1, 1 };

        P.SetData(values);


        comshader.SetBuffer(kernel, "P", P);//给compute shader设置P


        comshader.Dispatch(kernel, 32, 32, 1);

    }
	
	// Update is called once per frame
	void Update () {
	
	}

    private void OnRenderObject()
    {


         int[] values = {1, 2, 3};

        P.GetData(values);
        
        Debug.Log("vauls is " + values[1].ToString() + "vauls is " + values[0].ToString());
        int i = 0;
    }

}
