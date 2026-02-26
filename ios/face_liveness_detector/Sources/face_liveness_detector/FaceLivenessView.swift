import Flutter
import SwiftUI
import FaceLiveness
import Amplify

class FaceLivenessView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        handler: EventStreamHadler
    ) {
        _view = UIView()
        super.init()
        
        createNativeView(view: _view, arguments: args, handler: handler)
    }

    func view() -> UIView {
        return _view
    }
    
    func createNativeView(view _view: UIView, arguments args: Any?, handler: EventStreamHadler){
        guard let args = args as? [String: Any] else { return }
        
        let keyWindows = UIApplication.shared.windows.first(where: { $0.isKeyWindow}) ?? UIApplication.shared.windows.first
        let topController = keyWindows?.rootViewController
        
        let vc = UIHostingController(
            rootView: NativeView(
                sessionId: args["sessionId"] as! String,
                region: args["region"] as! String,
                disableStartView: (args["disableStartView"] as! NSNumber).boolValue,
                handler: handler
            )
        )
        
        let swiftUiView = vc.view!
        swiftUiView.translatesAutoresizingMaskIntoConstraints = false
        
        topController?.addChild(vc)
        _view.addSubview(swiftUiView)
        
        NSLayoutConstraint.activate(
            [
                swiftUiView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
                swiftUiView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
                swiftUiView.topAnchor.constraint(equalTo: _view.topAnchor),
                swiftUiView.bottomAnchor.constraint(equalTo:  _view.bottomAnchor)
            ])
        
        vc.didMove(toParent: topController)
    }
}

struct NativeView: View {
    let sessionId: String
    let region: String
    let disableStartView: Bool
    let handler: EventStreamHadler
    
    @State private var isPresentingLiveness = true
    
    init(sessionId: String, region: String, disableStartView: Bool,  handler: EventStreamHadler) {
        self.sessionId = sessionId
        self.region = region
        self.disableStartView = disableStartView
        self.handler = handler
    }

    var body: some View {
        FaceLivenessDetectorView(
            sessionID: self.sessionId,
            region: self.region,
            disableStartView: self.disableStartView,
            isPresented: $isPresentingLiveness,
            onCompletion: { result in
                switch result {
                case .success:
                    handler.onComplete()
                case .failure(let error):
                    switch error {
                    case .userCancelled:
                        handler.onError(code: "userCancelled")
                        return
                    case .sessionTimedOut:
                        handler.onError(code: "sessionTimedOut")
                        return
                    case .sessionNotFound:
                        handler.onError(code: "sessionNotFound")
                        return
                    default:
                        handler.onError(code: "error")
                        return
                    }
                default:
                    return
                }
            }
        )
    }
} 