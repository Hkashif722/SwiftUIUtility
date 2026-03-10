//
//  UIKitBridgeVCRepresentable.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 04/03/26.
//

import SwiftUI
import AVFoundation
import CoreImage
import SafariServices

class UIKitBridgeVCRepresentable: NSObject {
    
    static let sharedInstance = UIKitBridgeVCRepresentable()
    
    // Private initializer to prevent instantiation from outside
    private override init() {super.init()}
    
    struct ResourceViewRepresentable: UIViewControllerRepresentable {
        let filePath: String
        let isOnlineType: Bool
        
        func makeUIViewController(context: Context) -> UINavigationController {
            let vc = ResourceVC()
            vc.filePath = isOnlineType ? ResourceUtils.getResourcPath(filePath) : filePath
            vc.isOnline = isOnlineType
            vc.navigationItem.backButtonTitle = "toolbar_back_title".localized
            
            return UINavigationController(rootViewController: vc)
        }
        
        func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
            // No need to update anything here, since ResourceVC handles its own updates
        }
    }


    // MARK: - Updated PDFPreviewView
    public struct PDFPreviewView: UIViewControllerRepresentable {
        public typealias UIViewControllerType = UINavigationController

        public let navModel: NavigationViewModel.PdfViewerNavModel
        // Capture SwiftUI's dismiss at the struct level
        @Environment(\.dismiss) private var dismiss

        public init(navModel: NavigationViewModel.PdfViewerNavModel) {
            self.navModel = navModel
        }

        public class Coordinator {
            var navModel: NavigationViewModel.PdfViewerNavModel
            var dismiss: (() -> Void)?

            init(navModel: NavigationViewModel.PdfViewerNavModel) {
                self.navModel = navModel
            }

            func triggerDismiss() {
                navModel.onDismiss?()
                dismiss?()
            }
        }

        public func makeCoordinator() -> Coordinator {
            Coordinator(navModel: navModel)
        }

        public func makeUIViewController(context: Context) -> UINavigationController {
            let vc = PDFPreviewViewController()
            vc.pdfURL = navModel.pdfURL
            vc.courseID = navModel.courseID
            vc.moduleItem = navModel.moduleItem
            vc.isCallCourseCompletion = navModel.isCallCourseCompletion
            vc.showAlertOnBackButtonPressed = navModel.showAlertOnBackButtonPressed
            vc.onCompletion = navModel.onCompletion
            vc.onDismiss = { [weak coordinator = context.coordinator] in
                coordinator?.triggerDismiss()
            }
            return UINavigationController(rootViewController: vc)
        }

        public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
            // Keep the dismiss action fresh — @Environment values can change
            context.coordinator.dismiss = { dismiss() }
        }

        public func hidingSwiftUINavBar() -> some View {
            if #available(iOS 16.0, *) {
                return self.toolbar(.hidden, for: .navigationBar)
            } else {
                return self.navigationBarHidden(true)
            }
        }
    }
}
