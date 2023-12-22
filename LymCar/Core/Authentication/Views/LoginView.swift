//
//  LoginView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct LoginView: View {
    @State var emailText: String = ""
    @State var passwordText: String = ""
    @Binding var didLogin: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("로그인")
                    .font(.system(size: 40, weight: .heavy))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 21)
                    .foregroundStyle(.white)
                    .padding(.top, 100)
                
                VStack(spacing: 0) {
                    Text("로그인")
                        .font(.system(size: 24, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 27)
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    TextField(text: $emailText) {
                        Text("이메일을 입력해주세요")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 15)
                    .background(Color.theme.secondaryBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 17)
                    
                    TextField(text: $passwordText) {
                        Text("비밀번호를 입력해주세요")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 15)
                    .background(Color.theme.secondaryBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 10)
                    
                    NavigationLink {
                        RegisterView()
                    } label: {
                        HStack {
                            Text("아직 회원이 아니신가요?")
                                .foregroundStyle(Color.theme.primaryTextColor)
                                .font(.system(size: 14, weight: .medium))
                            Text("회원가입하러 가기")
                                .foregroundStyle(Color.theme.brandColor)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .padding(.vertical, 17)

                    Spacer()
                    
                    Button(action: {
                        print("DEBUG: 로그인")
                        didLogin.toggle()
                    }, label: {
                        Text("로그인")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    })
                    .background(Color.theme.brandColor)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.bottom, 47)
                }
                .padding(.horizontal, 21)
                .background(Color.theme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.top, 18)
                .ignoresSafeArea()
            }
            .background {
                Image("WelcomeBackgroundImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    LoginView(didLogin: .constant(false))
        .environmentObject(AuthViewModel(authManager: AuthManager()))
}
