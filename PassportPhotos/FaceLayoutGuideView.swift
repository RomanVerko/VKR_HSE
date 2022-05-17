
import SwiftUI

struct FaceLayoutGuideView: View {
  @ObservedObject private(set) var model: CameraViewModel

  var body: some View {
    Rectangle()
      .path(in: CGRect(
        x: model.faceLayoutGuideFrame.minX,
        y: model.faceLayoutGuideFrame.minY,
        width: model.faceLayoutGuideFrame.width,
        height: model.faceLayoutGuideFrame.height
      ))
      .stroke(Color.red)
  }
}

struct FaceLayoutGuideView_Previews: PreviewProvider {
  static var previews: some View {
    FaceLayoutGuideView(model: CameraViewModel())
  }
}
