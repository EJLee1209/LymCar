//
//  PrivacyPolicyView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct AnswerPrivacyPolicyView: View {
    @Binding var isAgreeForPrivacyPolicy: Bool
    @State private var privacyPolicyIsPresented = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            Button(action: {
                privacyPolicyIsPresented.toggle()
            }, label: {
                Text("개인정보처리방침")
                    .font(.system(size: 14, weight: .medium))
                    .underline()
                    .foregroundStyle(Color.theme.brandColor)
            })
            
            Text("에 동의합니다")
                .font(.system(size: 14))
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 1)
                .fill(isAgreeForPrivacyPolicy ? Color.theme.brandColor : Color.theme.secondaryTextColor)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        isAgreeForPrivacyPolicy.toggle()
                    }
                }
        }
        .sheet(isPresented: $privacyPolicyIsPresented, content: {
            ZStack (alignment: .bottom) {
                WebView(url: Constant.privacyPolicyURL)
                
                RoundedActionButton(label: "동의합니다") {
                    isAgreeForPrivacyPolicy = true
                    privacyPolicyIsPresented = false
                }
                .padding()
            }
        })
    }
}

#Preview {
    AnswerPrivacyPolicyView(isAgreeForPrivacyPolicy: .constant(false))
}
