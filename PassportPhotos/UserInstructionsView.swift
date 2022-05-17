
import SwiftUI

struct UserInstructionsView: View {
  @ObservedObject var model: CameraViewModel
  
  var body: some View {
    Text(faceDetectionStateLabel())
      .font(.title)
  }
}

// MARK: Private instance methods

extension UserInstructionsView {
  func faceDetectionStateLabel() -> String {
    
    switch model.faceDetectedState {
    case .faceDetectionErrored:
      return "An unexpected error occurred"
    case .noFaceDetected:
      return "Please look at the camera"
    case .faceDetected:
      if model.hasDetectedValidFace {
        return "OK. You're watching"
      } else if model.isAcceptableBounds == .detectedFaceTooSmall {
        return "Please bring your face closer to the camera"
      } else if model.isAcceptableBounds == .detectedFaceTooLarge {
        return "Please hold the camera further from your face"
      } else if model.isAcceptableBounds == .detectedFaceOffCentre {
        return "Please move your face to the centre of the frame"
      } else if !model.isAcceptableRoll || !model.isAcceptablePitch || !model.isAcceptableYaw {
        return "Please look straight at the camera"
      } else if !model.isAcceptableQuality {
        return "Image quality too low"
      } else {
        return "We cannot take your photo right now"
      }
    }
  }
}

struct UserInstructionsView_Previews: PreviewProvider {
  static var previews: some View {
    UserInstructionsView(
      model: CameraViewModel()
    )
  }
}
