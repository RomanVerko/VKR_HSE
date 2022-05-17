
import SwiftUI

struct LayoutGuideView: View {
  let layoutGuideFrame: CGRect
  let hasDetectedValidFace: Bool

  var body: some View {
    VStack {
      Ellipse()
        .stroke(hasDetectedValidFace ? Color.green : Color.red)
        .frame(width: layoutGuideFrame.width, height: layoutGuideFrame.height)
    }
  }
}

struct LayoutGuideView_Previews: PreviewProvider {
  static var previews: some View {
    LayoutGuideView(
      layoutGuideFrame: CGRect(x: 0, y: 0, width: 200, height: 300),
      hasDetectedValidFace: true
    )
  }
}
