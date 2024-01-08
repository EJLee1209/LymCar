//
//  AuthBackButton.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct AuthBackButton: View {
    @Binding var authStep: AuthStep
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
            if authStep.rawValue > 0 {
                authStep = AuthStep(rawValue: authStep.rawValue - 1)!
                if authStep == .emailVerification { authStep = .email }
            } else if authStep.rawValue == 0 {
                dismiss()
            }
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title2)
                
                Text(prevSubTitle())
            }
        })
        .tint(.white)
    }
    
    private func prevSubTitle() -> String {
        guard var prevStep = AuthStep(rawValue: authStep.rawValue - 1) else {
            return "로그인"
        }
        if prevStep == .emailVerification {
            prevStep = .email
        }
        
        return prevStep.subTitle
    }
}

#Preview {
    AuthBackButton(authStep: .constant(.privacyPolicy))
}
