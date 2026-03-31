//
//  ZoomableImagePreviewerView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import SwiftUI

public struct ZoomableImagePreviewerView: View {
    @Environment(\.router) var router
    let zoomableNavModel: NavigationViewModel.ZoomableViewNavModel
    
    public init(zoomableNavModel: NavigationViewModel.ZoomableViewNavModel) {
        self.zoomableNavModel = zoomableNavModel
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            ZoomableView {
                AsyncImageWithFallback(
                    urlString: zoomableNavModel.url?.absoluteString,
                    defaultImageName: ""
                )
                .scaledToFit()
            }
            
            backButtonView
        }
        .navigationBarHidden(true)
    }
    
    private var backButtonView: some View {
        SwiftUIUtility.CircleCloseButton(action: {
            print("check")
            router.dismissModal(id: "zoomableImageView")
        })
        .padding()
        .padding(.top, SwiftUIUtility.safeAreaTopPadding())
    }
}

#Preview {
    let imgUrl = URL(string: "https://content.gogetempowered.com//assets/img/Thumbnail_vectors/img_thumb10.jpg")!
    let model = NavigationViewModel.ZoomableViewNavModel(url: imgUrl)
    ZoomableImagePreviewerView(zoomableNavModel: model)
}
