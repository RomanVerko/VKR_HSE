
import SwiftUI
import UIKit

struct PassportPhotoView: View {
  let passportPhoto: UIImage

  var body: some View {
    VStack {
      Spacer()
      Image(uiImage: passportPhoto)
        .resizable()
        .aspectRatio(contentMode: .fit)
      Spacer()
    }
    .ignoresSafeArea()
    .background(.black)
  }
}

struct PassportPhotoView_Previews: PreviewProvider {
  static var previews: some View {
    if let image = UIImage(named: "rw-logo") {
      PassportPhotoView(passportPhoto: image)
    }
  }
}
