using UnityEngine;
using System.Collections;

public class MovablePointLit : MonoBehaviour {

    public GameObject Target;
	// Use this for initialization
	void Start () {
        
	}
	
	// Update is called once per frame
	void Update () {
        GetComponent<Renderer>().material.SetVector("_MoveDir", Target.transform.forward);
        GetComponent<Renderer>().material.SetVector("_MovePoint", Target.transform.position);
    }
}
