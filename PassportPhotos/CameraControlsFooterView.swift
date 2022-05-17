
import SwiftUI

struct CameraControlsFooterView: View {
  @ObservedObject var model: CameraViewModel

  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.black)
      CameraControlsView(model: model)
    }
  }

  struct CameraControlsView: View {
    @ObservedObject var model: CameraViewModel

    var body: some View {
      HStack(spacing: 20) {
        Spacer()
        VStack(spacing: 20) {
          HideBackgroundButton(isHideBackgroundEnabled: model.hideBackgroundModeEnabled) {
            model.perform(action: .toggleHideBackgroundMode)
          }
          DebugButton(isDebugEnabled: model.debugModeEnabled) {
            model.perform(action: .toggleDebugMode)
          }
        }
        Spacer()
        ShutterButton(isDisabled: !model.hasDetectedValidFace) {
          model.perform(action: .takePhoto)
        }
        Spacer()
        ThumbnailView(passportPhoto: model.passportPhoto)
        Spacer()
      }
    }
  }

  struct HideBackgroundButton: View {
    let isHideBackgroundEnabled: Bool
    let action: (() -> Void)

    var body: some View {
      Button(action: {
        action()
      }, label: {
        FooterIconView(imageName: "photo.fill")
      })
        .tint(isHideBackgroundEnabled ? .green : .gray)
    }
  }

  struct DebugButton: View {
    let isDebugEnabled: Bool
    let action: (() -> Void)

    var body: some View {
      Button(action: {
        action()
      }, label: {
        FooterIconView(imageName: "ladybug.fill")
      })
        .tint(isDebugEnabled ? .green : .gray)
    }
  }

  struct ShutterButton: View {
    let isDisabled: Bool
    let action: (() -> Void)

    var body: some View {
      Button(action: {
        action()
      }, label: {
        Image(systemName: "camera.aperture")
          .font(.system(size: 72))
      })
        .disabled(isDisabled)
        .tint(.white)
    }
  }

  struct ThumbnailView: View {
    let passportPhoto: UIImage?

    @State private var isShowingPassportPhoto = false

    var body: some View {
      if let photo = passportPhoto {
        VStack {
          NavigationLink(
            destination: PassportPhotoView(passportPhoto: photo),
            isActive: $isShowingPassportPhoto
          ) {
            EmptyView()
          }
          Button(action: {
            isShowingPassportPhoto = true
          }, label: {
            Image(uiImage: photo)
              .resizable()
              .frame(width: 45.0, height: 60.0)
          })
        }
      } else {
        FooterIconView(imageName: "photo.fill.on.rectangle.fill")
          .foregroundColor(.gray)
      }
    }
  }

  struct FooterIconView: View {
    var imageName: String

    var body: some View {
      return Image(systemName: imageName)
        .font(.system(size: 36))
    }
  }
}

struct CameraControlsFooterView_Previews: PreviewProvider {
  static var previews: some View {
    CameraControlsFooterView(model: CameraViewModel())
  }
}
