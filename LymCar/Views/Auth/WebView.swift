//
//  PrivacyPolicyWebView.swift
//  LymCar
//
//  Created by 이은재 on 1/12/24.
//

import SwiftUI

struct WebView: View {
    let url: String
    
    var body: some View {
        WKWebViewRepresentable(url: url)
//            .ignoresSafeArea()
    }
}

#Preview {
    WebView(url: Constant.privacyPolicyURL)
}
