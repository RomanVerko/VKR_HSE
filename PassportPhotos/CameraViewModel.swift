
import Combine
import CoreGraphics
import UIKit
import Vision


class GlobalString: ObservableObject {
  @Published var selected = true
}


enum CameraViewModelAction {
  // View setup and configuration actions
  case windowSizeDetected(CGRect)

  // Face detection actions
  case noFaceDetected
  case faceObservationDetected(FaceGeometryModel)
  case faceQualityObservationDetected(FaceQualityModel)

  // Other
  case toggleDebugMode
  case toggleHideBackgroundMode
  case takePhoto
  case savePhoto(UIImage)
}

enum FaceDetectedState {
  case faceDetected
  case noFaceDetected
  case faceDetectionErrored
}

enum FaceBoundsState {
  case unknown
  case detectedFaceTooSmall
  case detectedFaceTooLarge
  case detectedFaceOffCentre
  case detectedFaceAppropriateSizeAndPosition
}

struct FaceGeometryModel {
  let boundingBox: CGRect
  let roll: NSNumber
  let pitch: NSNumber
  let yaw: NSNumber
  let time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()}

struct FaceQualityModel {
  let quality: Float
}


final public class CameraViewModel: ObservableObject {
  // MARK: - Publishers
  @Published var debugModeEnabled: Bool
  @Published var hideBackgroundModeEnabled: Bool

  // MARK: - Publishers of derived state
  @Published private(set) var timerOn: Bool
  @Published private(set) var hasDetectedValidFace: Bool
  @Published private(set) var isAcceptableRoll: Bool {
    didSet {
      calculateDetectedFaceValidity()
    }
  }
  @Published private(set) var isAcceptablePitch: Bool {
    didSet {
      calculateDetectedFaceValidity()
    }
  }
  @Published private(set) var isAcceptableYaw: Bool {
    didSet {
      calculateDetectedFaceValidity()
    }
  }
  @Published private(set) var isAcceptableBounds: FaceBoundsState {
    didSet {
      calculateDetectedFaceValidity()
    }
  }
  @Published private(set) var isAcceptableQuality: Bool {
    didSet {
      calculateDetectedFaceValidity()
    }
  }
  @Published private(set) var passportPhoto: UIImage?

  // MARK: - Publishers of Vision data directly
  @Published private(set) var faceDetectedState: FaceDetectedState
  @Published private(set) var faceGeometryState: FaceObservation<FaceGeometryModel> {
    didSet {
      processUpdatedFaceGeometry()
    }
  }

  @Published private(set) var faceQualityState: FaceObservation<FaceQualityModel> {
    didSet {
      processUpdatedFaceQuality()
    }
  }

  // MARK: - Public properties
  let shutterReleased = PassthroughSubject<Void, Never>()

  // MARK: - Private variables
  var faceLayoutGuideFrame = CGRect(x: 0, y: 0, width: 0, height: 0)

  init() {
    faceDetectedState = .noFaceDetected
    isAcceptableRoll = false
    isAcceptablePitch = false
    isAcceptableYaw = false
    isAcceptableBounds = .unknown
    isAcceptableQuality = false
    timerOn = false

    hasDetectedValidFace = false
    faceGeometryState = .faceNotFound
    faceQualityState = .faceNotFound

    #if DEBUG
      debugModeEnabled = true
    #else
      debugModeEnabled = false
    #endif
    hideBackgroundModeEnabled = false
  }

  // MARK: Actions

  func perform(action: CameraViewModelAction) {
    switch action {
    case .windowSizeDetected(let windowRect):
      handleWindowSizeChanged(toRect: windowRect)
    case .noFaceDetected:
      publishNoFaceObserved()
    case .faceObservationDetected(let faceObservation):
      publishFaceObservation(faceObservation)
    case .faceQualityObservationDetected(let faceQualityObservation):
      publishFaceQualityObservation(faceQualityObservation)
    case .toggleDebugMode:
      toggleDebugMode()
    case .toggleHideBackgroundMode:
      toggleHideBackgroundMode()
    case .takePhoto:
      takePhoto()
    case .savePhoto(let image):
      savePhoto(image)
    }
  }

  // MARK: Action handlers

  private func handleWindowSizeChanged(toRect: CGRect) {
    faceLayoutGuideFrame = CGRect(
      x: toRect.midX - faceLayoutGuideFrame.width / 2,
      y: toRect.midY - faceLayoutGuideFrame.height / 2,
      width: faceLayoutGuideFrame.width,
      height: faceLayoutGuideFrame.height
    )
  }

  private func publishNoFaceObserved() {
    DispatchQueue.main.async { [self] in
      faceDetectedState = .noFaceDetected
      faceGeometryState = .faceNotFound
      faceQualityState = .faceNotFound
    }
  }

  private func publishFaceObservation(_ faceGeometryModel: FaceGeometryModel) {
    DispatchQueue.main.async { [self] in
      faceDetectedState = .faceDetected
      faceGeometryState = .faceFound(faceGeometryModel)
    }
  }

  private func publishFaceQualityObservation(_ faceQualityModel: FaceQualityModel) {
    DispatchQueue.main.async { [self] in
      faceDetectedState = .faceDetected
      faceQualityState = .faceFound(faceQualityModel)
    }
  }

  private func toggleDebugMode() {
    debugModeEnabled.toggle()
  }

  private func toggleHideBackgroundMode() {
    hideBackgroundModeEnabled.toggle()
  }

  private func takePhoto() {
    shutterReleased.send()
  }

  private func savePhoto(_ photo: UIImage) {
    UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
    DispatchQueue.main.async { [self] in
      passportPhoto = photo
    }
  }
}

// MARK: Private instance methods


extension CameraViewModel {
  func invalidateFaceGeometryState() {
    isAcceptableRoll = false
    isAcceptablePitch = false
    isAcceptableYaw = false
    isAcceptableBounds = .unknown
  }

  func processUpdatedFaceGeometry() {
    switch faceGeometryState {
    case .faceNotFound:
      invalidateFaceGeometryState()
    case .errored(let error):
      print(error.localizedDescription)
      invalidateFaceGeometryState()
    case .faceFound(let faceGeometryModel):
      let boundingBox = faceGeometryModel.boundingBox
      let roll = faceGeometryModel.roll.doubleValue
      let pitch = faceGeometryModel.pitch.doubleValue
      let yaw = faceGeometryModel.yaw.doubleValue

      updateAcceptableBounds(using: boundingBox)
      updateAcceptableRollPitchYaw(using: roll, pitch: pitch, yaw: yaw)
    }
  }

  func updateAcceptableBounds(using boundingBox: CGRect) {
    // First, check face is roughly the same size as the layout guide
    if boundingBox.width * 1.2 < 200 {
      isAcceptableBounds = .detectedFaceTooSmall
    }
     else {
        isAcceptableBounds = .detectedFaceAppropriateSizeAndPosition
      }
  }

  func updateAcceptableRollPitchYaw(using roll: Double, pitch: Double, yaw: Double) {
    isAcceptableRoll = (roll > 1.2 && roll < 1.6)
    isAcceptablePitch = abs(CGFloat(pitch)) < 0.2
    isAcceptableYaw = abs(CGFloat(yaw)) < 0.15
  }

  func processUpdatedFaceQuality() {
    switch faceQualityState {
    case .faceNotFound:
      isAcceptableQuality = false
      timerOn = false
    case .errored(let error):
      print(error.localizedDescription)
      isAcceptableQuality = false
      timerOn = false
    case .faceFound(let faceQualityModel):
      if faceQualityModel.quality < 0.2 {
        isAcceptableQuality = false
        timerOn = false
      }

      isAcceptableQuality = true
      timerOn = true
    }
  }

  
  func calculateDetectedFaceValidity() {
    hasDetectedValidFace =
    isAcceptableBounds == .detectedFaceAppropriateSizeAndPosition &&
    isAcceptableRoll &&
    isAcceptablePitch &&
    isAcceptableYaw &&
    isAcceptableQuality
    
  }
  
  
  public func isValidFace() -> Bool {
    return hasDetectedValidFace
  }
}
