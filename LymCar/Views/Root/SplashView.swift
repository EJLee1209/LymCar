//
//  SplashView.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Image("WelcomeBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VisualEffectViewRepresentable(effect: UIBlurEffect(style: .dark))
                .ignoresSafeArea()
            
            VStack {
                Image("character")
                
                Text("Welcome!")
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .bold))
                
                Text("림카에 오신걸 환영합니다")
                    .foregroundStyle(.white)
                    .font(.body)
            }
            
            
        }
        
    }
}

#Preview {
    SplashView()
}
