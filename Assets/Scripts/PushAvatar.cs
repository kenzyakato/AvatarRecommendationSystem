using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PushAvatar : MonoBehaviour
{
    public GameObject avatar;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    public void CreatAvatar()
    {
        Instantiate(avatar,transform.parent);
    }
}
