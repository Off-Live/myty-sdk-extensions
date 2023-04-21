using System.Collections.Generic;
using Avatar;
using Data;
using Newtonsoft.Json;
using UnityEngine;

namespace MessageHandler
{
    public class MessageHandler : MonoBehaviour
    {
        public AvatarLoader avatarLoader;
        public Avatar3DLoader avatar3DLoader;
        public AvatarManager avatarManager;
        public MotionSource.MotionSource motionSource;

        void Start()
        {
            avatarLoader = FindObjectOfType<AvatarLoader>();
            avatarManager = FindObjectOfType<AvatarManager>();
            motionSource = FindObjectOfType<MotionSource.MotionSource>();
            avatar3DLoader = FindObjectOfType<Avatar3DLoader>();
        }
        
        public void LoadAvatar(string message)
        {
            var obj = JsonConvert.DeserializeObject<LoadAvatarMessage>(message);
            avatarLoader.LoadAvatar(
                obj!.avatarCollectionId,
                obj!.metadataAssetUri,
                obj!.tokenId,
                obj!.tokenAssetUri
            );
        }

        public void SelectAvatar(string message)
        {
            var obj = JsonConvert.DeserializeObject<SelectAvatarMessage>(message);
            avatarManager.SelectAvatar(
                obj!.avatarCollectionId,
                obj!.tokenId
            );
        }

        public void SetARMode(string flag)
        {
            avatarManager.SetARMode(flag == "true");
        }

        public void Load3DAvatar()
        {
            avatar3DLoader.Load3DAvatarTest();
        }

        public void ProcessCapturedResult(string message)
        {
            motionSource.ProcessCapturedResult(message);
        }
    }
}