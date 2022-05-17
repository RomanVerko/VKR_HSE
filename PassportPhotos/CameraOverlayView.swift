
import SwiftUI

struct CameraOverlayView: View {
  @ObservedObject private(set) var model: CameraViewModel

  var body: some View {
    GeometryReader { geometry in
      VStack {
        CameraControlsHeaderView(model: model)
        Spacer()
          .frame(height: geometry.size.width * 4 / 3)
        CameraControlsFooterView(model: model)
      }
    }
  }
}

struct CameraControlsView_Previews: PreviewProvider {
  static var previews: some View {
    CameraOverlayView(model: CameraViewModel())
  }
}
