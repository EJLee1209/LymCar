//
//  퍋ㅈ.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func loadingProgress<T: Decodable & Equatable>(viewState: ViewState<T>) -> some View {
        modifier(LoadingViewModifier(viewState: viewState))
    }
    
    func alert(role: AlertRole, alertMessage: String, isPresented: Binding<Bool>) -> some View {
        modifier(AlertModifier(role: role, alertMessage: alertMessage, isPresented: isPresented))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}
