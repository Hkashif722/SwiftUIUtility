import SwiftUI
import AVKit

public struct UIKitComponentRepresentable {
      
    public struct PlayerKitView: UIViewControllerRepresentable {
        public var videoURL: URL

        public init(videoURL: URL) {
            self.videoURL = videoURL
        }
        
        public func makeUIViewController(context: Context) -> AVPlayerViewController {
            let playerVC = AVPlayerViewController()
            let player = AVPlayer(url: videoURL)
            playerVC.player = player
            playerVC.showsPlaybackControls = true
            return playerVC
        }
        
        public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    }
    
    public struct GIFWebView: UIViewRepresentable {
        public let gifName: String

        public init(gifName: String) {
            self.gifName = gifName
        }

        public func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.scrollView.isScrollEnabled = false
            webView.backgroundColor = .clear
            webView.isOpaque = false

            if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
                let data = try? Data(contentsOf: URL(fileURLWithPath: path))
                webView.load(data!, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: path))
            }

            return webView
        }

        public func updateUIView(_ uiView: WKWebView, context: Context) {}
    }
    
    public struct WindowSecureLayerView: UIViewRepresentable {

        public init() {}

        public func makeUIView(context: Context) -> UIView {
            DispatchQueue.main.async {
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows.first {
                    makeSecure(window: window)
                }
            }
            return UIView()
        }
        
        public func updateUIView(_ uiView: UIView, context: Context) {}
        
        public func makeSecure(window: UIWindow) {
            let field = UITextField()
            field.isSecureTextEntry = true
            
            let view = UIView(frame: field.frame)
            let image = UIImageView(image: UIImage(named: "yourPlaceHolderImage") ?? UIImage())
            image.frame = UIScreen.main.bounds
            
            window.addSubview(field)
            view.addSubview(image)
            
            if let superlayer = window.layer.superlayer {
                superlayer.addSublayer(field.layer)
                if let lastLayer = field.layer.sublayers?.last {
                    lastLayer.addSublayer(window.layer)
                }
            }
            
            field.leftView = view
            field.leftViewMode = .always
        }
    }
}
