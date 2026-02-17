import SwiftUI
import AVKit
import WebKit 

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
    
    /// GIF WebView for displaying animated GIFs
    public struct GIFWebView: UIViewRepresentable {
        let gifName: String
        
        public init(gifName: String) {
            self.gifName = gifName
        }
        
        public func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.scrollView.isScrollEnabled = false
            webView.backgroundColor = .clear
            webView.isOpaque = false
            return webView
        }
        
        public func updateUIView(_ webView: WKWebView, context: Context) {
            guard let url = Bundle.swiftUIUtilitiesModule.url(forResource: gifName, withExtension: "gif"),
                  let data = try? Data(contentsOf: url) else {
                return
            }
            
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: url.deletingLastPathComponent()
            )
        }
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
