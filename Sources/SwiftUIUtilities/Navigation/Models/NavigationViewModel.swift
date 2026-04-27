//
//  NavigationViewModel.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation
import UniformTypeIdentifiers

public struct NavigationViewModel {
    
    public struct AlertViewModel {
        public var title: String?
        public let message: String
        
        public var okAction: (() -> Void)? = nil
        public var cancelAction: (() -> Void)? = nil
        
        public init(
            title: String? = nil,
            message: String,
            okAction: (() -> Void)? = nil,
            cancelAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.message = message
            self.okAction = okAction
            self.cancelAction = cancelAction
        }
    }
    
    public struct DocumentPickerModel {
        public let allowedContentTypes: [UTType]
        public let fileURLProvider: ((URL?) -> Void)
        
        public init(
            allowedContentTypes: [UTType] = [.item],
            fileURLProvider: @escaping (URL?) -> Void
        ) {
            self.allowedContentTypes = allowedContentTypes
            self.fileURLProvider = fileURLProvider
        }
    }
    
    public struct MultiDocumentPickerModel {
        public let fileURLProvider: (([URL]?) -> ())
        
        public init(fileURLProvider: @escaping ([URL]?) -> Void) {
            self.fileURLProvider = fileURLProvider
        }
    }
    
    public struct ResourceViewModel {
        public let filePath: String
        public let isOnlineType: Bool
        
        public init(filePath: String, isOnlineType: Bool) {
            self.filePath = filePath
            self.isOnlineType = isOnlineType
        }
    }
    
    // MARK: - Updated PdfViewerNavModel
    public struct PdfViewerNavModel {
        public let pdfURL: URL
        public let isCallCourseCompletion: Bool
        public var courseID: Int32?
        public var moduleItem: PDFModuleItem?
        public var status: String
        public var showAlertOnBackButtonPressed: Bool
        public var onCompletion: ((PDFCompletionPayload) -> Void)?
        public var onDismiss: (() -> Void)?

        public init(
            pdfURL: URL,
            isCallCourseCompletion: Bool = false,
            courseID: Int32? = nil,
            moduleItem: PDFModuleItem? = nil,
            status: String = "",
            showAlertOnBackButtonPressed: Bool = true,
            onCompletion: ((PDFCompletionPayload) -> Void)? = nil,
            onDismiss: (() -> Void)? = nil
        ) {
            self.pdfURL = pdfURL
            self.isCallCourseCompletion = isCallCourseCompletion
            self.courseID = courseID
            self.moduleItem = moduleItem
            self.status = status
            self.showAlertOnBackButtonPressed = showAlertOnBackButtonPressed
            self.onCompletion = onCompletion
            self.onDismiss = onDismiss
        }
    }
    
    public struct ZoomableViewNavModel {
        public let url: URL?
        
        public init(url: URL?) {
            self.url = url
        }
    }
    
    public struct AudioPlayerNavModel {
        public var audioURL: URL
        public var audioTitle: String?
        
        public init(audioURL: URL, audioTitle: String? = nil) {
            self.audioURL = audioURL
            self.audioTitle = audioTitle
        }
    }
    
    public struct FileDownloadPickerNavModel {
        public let temporaryFileURL: URL
        public let suggestedFileName: String
        public let onCompletion: (URL?) -> Void
        
        public init(temporaryFileURL: URL, suggestedFileName: String, onCompletion: @escaping (URL?) -> Void) {
            self.temporaryFileURL = temporaryFileURL
            self.suggestedFileName = suggestedFileName
            self.onCompletion = onCompletion
        }
    }
    
}
