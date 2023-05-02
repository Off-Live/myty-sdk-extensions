using Data;
using Motion.ARKit.RiggingModels;
using Newtonsoft.Json;

namespace Motion.ARKit
{
    public class ARKitMotionSource : Motion.MotionSource.MotionSource
    {
        protected override void ConvertCapturedResult(string result)
        {
            var obj = JsonConvert.DeserializeObject<ARKitData>(result);
            
            var headBridge = GetBridgesInCategory("Anchors");
            foreach (var bridge in headBridge)
            {
                var arHeadRotation = bridge as ARHeadRotation;
                arHeadRotation.up = obj!.up;
                arHeadRotation.lookAt = obj!.forward;
                arHeadRotation.position = obj!.facePosition;
                arHeadRotation.scale = obj!.faceScale;
                arHeadRotation.Flush();
            }
            
            var parametricBridge = GetBridgesInCategory("Parametric");
            foreach (var bridge in parametricBridge)
            {
                var simpleFace = bridge as ARKitSimpleFace;
                simpleFace.SetBlendshapes(obj!.blendshapes);
            }

            foreach (var bridge in parametricBridge)
            {
                bridge.Flush();
            }
        }
    }
}