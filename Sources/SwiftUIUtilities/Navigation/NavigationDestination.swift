//
//  NavigationDestination.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 20/01/26.
//

import SwiftUI

// MARK: - Navigation Destination
@MainActor
public enum NavigationDestination: NavigationProtocol {
    
    case customAlertPopupView(CustomAlertPopupModel)
    case showDocumentPickerView(NavigationViewModel.DocumentPickerModel)
    case showPhotoPickerView(NavigationViewModel.DocumentPickerModel)
    case showMultiPhotoPickerView(NavigationViewModel.MultiDocumentPickerModel)
    case showVideoPickerView(NavigationViewModel.DocumentPickerModel)
    case resourceView(NavigationViewModel.ResourceViewModel)
    case pdfViewerNavModel(NavigationViewModel.PdfViewerNavModel)
    case emptyView

    // MARK: - Navigation Logic
    public func navigate(using router: AnyRouter) {
        switch self {
        case .customAlertPopupView(let customAlertPopupModel):
            showModelViewWithoutDismissBackground(router) {
                CustomAlertPopupView(model: customAlertPopupModel)
            }
            
        case .showDocumentPickerView(let documentPickerModel):
            showSheetView(router) { router in
                DocumentPicker(onDocumentPicked: documentPickerModel.fileURLProvider)
            }
            
        case .showPhotoPickerView(let documentPickerModel):
            showSheetView(router) { router in
                PhotoPicker(onPhotoPicked: documentPickerModel.fileURLProvider)
            }
            
        case .showMultiPhotoPickerView(let documentPickerModel):
            showSheetView(router) { router in
                MultiPhotoPicker(onPhotosPicked: documentPickerModel.fileURLProvider)
            }
            
        case .showVideoPickerView(let documentPickerModel):
            showSheetView(router) { router in
                VideoPicker(onVideoPicked: documentPickerModel.fileURLProvider)
            }
            
        case .resourceView(let resourceViewModel):
            pushScreen(router) { router in
                UIKitBridgeVCRepresentable.ResourceViewRepresentable(
                    filePath: resourceViewModel.filePath,
                    isOnlineType: resourceViewModel.isOnlineType
                )
            }
            
        case .pdfViewerNavModel(let pdfViewerNavModel):
            pushScreen(router) { router in
                UIKitBridgeVCRepresentable.PDFPreviewView(navModel: pdfViewerNavModel)
                    .hidingSwiftUINavBar()
            }
            
        case .emptyView:
            pushScreen(router) { router in
                EmptyView()
            }
        }
    }
}
