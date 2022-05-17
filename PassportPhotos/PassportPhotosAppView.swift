
import SwiftUI

struct PassportPhotosAppView: View {
  @ObservedObject private(set) var model: CameraViewModel

  init(model: CameraViewModel) {
    self.model = model
  }

  var body: some View {
    GeometryReader { geo in
      NavigationView {
        ZStack {
          CameraView(model: model)
          LayoutGuideView(
            layoutGuideFrame: model.faceLayoutGuideFrame,
            hasDetectedValidFace: model.hasDetectedValidFace
          )
          if model.debugModeEnabled {
            DebugView(model: model)
          }
          CameraOverlayView(model: model)
        }
        .ignoresSafeArea()
        .onAppear {
          model.perform(action: .windowSizeDetected(geo.frame(in: .global)))
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    PassportPhotosAppView(model: CameraViewModel())
  }
}
