//
//  LoadingViewModifier.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import SwiftUI

struct LoadingViewModifier<T: Decodable & Equatable>: ViewModifier {
    @Binding var viewState: ViewState<T>
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if viewState == .loading {
                VisualEffectViewRepresentable(effect: UIBlurEffect(style: .dark))
                    .ignoresSafeArea()
                    .opacity(0.9)
                
                ProgressView()
            }
        }
        
    }
}
