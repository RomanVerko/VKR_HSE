
import SwiftUI
import Firebase

@main
struct AppMain: App {
  
  init() {
   FirebaseApp.configure()
  }
  
  var body: some Scene {
    WindowGroup {
      PassportPhotosAppView(model: CameraViewModel())
    }
  }
}
