
import SwiftUI
import FirebaseCore
import FirebaseFirestore


struct CameraControlsHeaderView: View {
  @ObservedObject var model: CameraViewModel
  @State public var isTimerRunning = true
  @State private var startTime =  Date()
  @State private var timerString = "0.00"
  @State private var allTimeString = "0.00"
  @State var okTime = 0.0
  @State var allTime = 0.0
  let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

  let db = Firestore.firestore()


  var body: some View {
    var date = Date()
    
    ZStack {
      Rectangle()
        .fill(Color.black)
      VStack{
        UserInstructionsView(model: model)
          .padding(.top, 50)
        Spacer()
        Text("okTime: \(self.timerString), allTime: \(allTimeString), perc: \(String(format: "%.0f",okTime/allTime*100))")
          .padding(.bottom)
            .onReceive(timer) { _ in
              if model.hasDetectedValidFace {
                okTime = okTime + 0.01
                timerString = String(format: "%.1f", okTime)
                date = Date()
              }
              allTime = allTime + 0.01
              allTimeString = String(format: "%.1f", allTime)
              

              let formatter4 = DateFormatter()
              formatter4.dateFormat = "HH:mm E, d MMM y"
              
              let curDTTM = formatter4.string(from: date)
              var ref: DocumentReference? = nil
              ref = db.collection("\(curDTTM)").addDocument(data: [
                  "Alltime": allTimeString,
                  "OKtime": timerString,
                  "persentage": String(format: "%.0f",okTime/allTime*100)
              ]) { err in
                  if let err = err {
                      print("Error adding document: \(err)")
                  } else {
                      print("Document added with ID: \(ref!.documentID)")
                  }
              }
          }
            
      }
    }
  }
}

struct CameraControlsHeaderView_Previews: PreviewProvider {
  static var previews: some View {
    CameraControlsHeaderView(model: CameraViewModel())
  }
}
