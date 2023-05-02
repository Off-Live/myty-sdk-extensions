
using Motion.Data;
using UnityEngine;

namespace Motion.MotionTemplateBridge
{
    public abstract class AnchorBridge : MotionTemplateBridge
    {
        public Vector3 up;
        public Vector3 lookAt;
        public Vector3 position;
        public Vector3 scale;

        public override BridgeItem CreateItem()
        {
            return new AnchorBridgeItem
            {
                up = up,
                lookAt = lookAt,
                position = position,
                scale = scale
            };
        }
    }
}