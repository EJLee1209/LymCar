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
            } else if authStep.rawValue == 0 {
                dismiss()
            }
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.title2)
                
                Text(AuthStep(rawValue: authStep.rawValue - 1)?.subTitle ?? "로그인")
            }
        })
        .tint(.white)
    }
}

#Preview {
    AuthBackButton(authStep: .constant(.privacyPolicy))
}
