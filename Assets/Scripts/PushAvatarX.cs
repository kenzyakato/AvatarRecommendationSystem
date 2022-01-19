using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PushAvatarX : MonoBehaviour
{
    public GameObject avatar;
    private int buttonID;
    private int imageID;
    // Start is called before the first frame update

    private void Update()
    {
        if (avatar != null)
        {
            avatar.transform.Rotate(Vector3.up * 30 * Time.deltaTime);
        }
    }
    // Update is called once per frame
    public void CreatAvatar()
    {
        if (avatar != null)
        {
            Destroy(avatar);
        }
        
        imageID = ButtonDownX.avatarID;
        string fname = "Avatar/" +imageID.ToString();
        Debug.Log(fname);
        avatar = Instantiate((GameObject)Resources.Load(fname));
        avatar.transform.position = this.transform.position;
        avatar.transform.rotation = this.transform.rotation;
        
    }
}
