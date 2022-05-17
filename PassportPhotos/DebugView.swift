
import SwiftUI


struct DebugView: View {
  @ObservedObject var model: CameraViewModel

  @State public var isTimerRunning = true
  @State private var startTime =  Date()
  @State private var timerString = "0.00"
  let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

  var body: some View {
    
   
    ZStack {
      FaceBoundingBoxView(model: model)
      FaceLayoutGuideView(model: model)
      VStack(alignment: .leading, spacing: 5) {
        DebugSection(observation: model.faceGeometryState) { geometryModel in
          DebugText("R: \(geometryModel.roll)")
            .debugTextStatus(status: model.isAcceptableRoll ? .passing : .failing)
          DebugText("P: \(geometryModel.pitch)")
            .debugTextStatus(status: model.isAcceptablePitch ? .passing : .failing)
          DebugText("Y: \(geometryModel.yaw)")
            .debugTextStatus(status: model.isAcceptableYaw ? .passing : .failing)
//          DebugText("Timer: \(self.timerString)")
//              .onReceive(timer) { _ in
//                if true {
//                      timerString = String(format: "%.2f", (Date().timeIntervalSince( self.startTime)))
//                  }
//              }
        }
        DebugSection(observation: model.faceQualityState) { qualityModel in
          DebugText("Q: \(qualityModel.quality)")
            .debugTextStatus(status: model.isAcceptableQuality ? .passing : .failing)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct DebugSection<Model, Content: View>: View {
  let observation: FaceObservation<Model>
  let content: (Model) -> Content

  public init(
    observation: FaceObservation<Model>,
    @ViewBuilder content: @escaping (Model) -> Content
  ) {
    self.observation = observation
    self.content = content
  }

  var body: some View {
    switch observation {
    case .faceNotFound:
      AnyView(Spacer())
    case .faceFound(let model):
      AnyView(content(model))
    case .errored(let error):
      AnyView(
        DebugText("ERROR: \(error.localizedDescription)")
      )
    }
  }
}

enum DebugTextStatus {
  case neutral
  case failing
  case passing
}

struct DebugText: View {
  let content: String

  @inlinable
  public init(_ content: String) {
    self.content = content
  }

  var body: some View {
    Text(content)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct Status: ViewModifier {
  let foregroundColor: Color

  func body(content: Content) -> some View {
    content
      .foregroundColor(foregroundColor)
  }
}

extension DebugText {
  func colorForStatus(status: DebugTextStatus) -> Color {
    switch status {
    case .neutral:
      return .white
    case .failing:
      return .red
    case .passing:
      return .green
    }
  }

  func debugTextStatus(status: DebugTextStatus) -> some View {
    self.modifier(Status(foregroundColor: colorForStatus(status: status)))
  }
}

struct DebugView_Previews: PreviewProvider {
  static var previews: some View {
    DebugView(model: CameraViewModel())
  }
}
