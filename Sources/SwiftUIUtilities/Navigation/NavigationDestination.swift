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
    case showPassthroughVideoPickerView(NavigationViewModel.DocumentPickerModel)
    case resourceView(NavigationViewModel.ResourceViewModel)
    case pdfViewerNavModel(NavigationViewModel.PdfViewerNavModel)
    case zoomableImageView(NavigationViewModel.ZoomableViewNavModel)
    case audioPlayerNavModel(NavigationViewModel.AudioPlayerNavModel)
    case showFileDowloadPicker(NavigationViewModel.FileDownloadPickerNavModel)
    case datePicker(NavigationViewModel.DatePickerNavModel)
    case timePicker(NavigationViewModel.TimePickerNavModel)
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
                DocumentPicker(allowedContentTypes: documentPickerModel.allowedContentTypes ,onDocumentPicked: documentPickerModel.fileURLProvider)
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
            
        case .showPassthroughVideoPickerView(let documentPickerModel):
            showSheetView(router) { router in
                VideoPickerPassthrough(onVideoPicked: documentPickerModel.fileURLProvider)
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
            
        case .zoomableImageView(let zoomableViewModel):
            showZoomableImage(router, zoomableViewModel: zoomableViewModel)
            
        case .audioPlayerNavModel( let audioPlayerNavModel):
            pushScreen(router) { router in
                AudioMediaPlayerView(audioPlayerNavModel, router: router)
            }
            
        case .showFileDowloadPicker(let folderPickerNavModel):
            showSheetView(router) { router in
                FileDownloadPicker(model: folderPickerNavModel)
            }
            
        case .datePicker(let datePickerNavModel):
            showModelView(router) {
                DatePickerView(navModel: datePickerNavModel, router: router)
            }

        case .timePicker(let timePickerNavModel):
            showModelView(router) {
                TimePickerView(navModel: timePickerNavModel, router: router)
            }

        case .emptyView:
            pushScreen(router) { router in
                EmptyView()
            }
        }
    }
    
    // Show a modal for ZoomableImage
    func showZoomableImage(_ router: AnyRouter, zoomableViewModel: NavigationViewModel.ZoomableViewNavModel) {
        if #available(iOS 16, *) {
            router.showModal(
                id: "zoomableImageView",
                transition: .move(edge: .top),
                animation: .easeInOut,
                alignment: .top,
                dismissOnBackgroundTap: true,
                ignoreSafeArea: true
            ) {
                ZoomableImagePreviewerView(zoomableNavModel: zoomableViewModel)
                    .dynamicTypeSize(.medium)
            }
        } else {
            self.showSheetView(router) { router in
                ZoomableImagePreviewerView(zoomableNavModel: zoomableViewModel)
                    .dynamicTypeSize(.medium)
            }
        }
    }
}
