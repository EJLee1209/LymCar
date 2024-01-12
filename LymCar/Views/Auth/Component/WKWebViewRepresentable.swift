//
//  WKWebViewRepresentable.swift
//  LymCar
//
//  Created by 이은재 on 1/12/24.
//
import SwiftUI
import WebKit

struct WKWebViewRepresentable: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url) else {
            return WKWebView()
        }
        let webView = WKWebView()
        
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: url) else { return }
        
        webView.load(URLRequest(url: url))
    }
}
