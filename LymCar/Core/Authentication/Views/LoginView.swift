//
//  LoginView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("email") var emailText: String = ""
    @State var passwordText: String = ""
    @Binding var didLogin: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome!")
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
                        
                        AuthTextField(
                            text: $emailText,
                            inputType: .email,
                            height: 50,
                            isShowTitle: false
                        )
                        .padding(.top, 17)
                        
                        AuthTextField(
                            text: $passwordText,
                            inputType: .password,
                            height: 50,
                            isShowTitle: false
                        )
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
                            viewModel.signIn(withEmail: emailText, password: passwordText)
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
                .alert(
                    viewModel.authResult.alertMessage,
                    isPresented: .constant(viewModel.authResult.alertIsPresented)
                ) {
                    Button {
                        viewModel.authResult = .none
                    } label: {
                        Text("확인")
                            .font(.system(size: 15))
                    }
                }
                .onReceive(viewModel.$authResult) { authResult in
                    if authResult == .successToSignIn {
                        didLogin.toggle()
                    }
                }
                
                if viewModel.authResult == .loading {
                    VisualEffectView(effect: UIBlurEffect(style: .dark))
                        .ignoresSafeArea()
                        .opacity(0.9)
                    
                    ProgressView()
                }
            }
            
        }
    }
}

#Preview {
    LoginView(didLogin: .constant(false))
        .environmentObject(AuthViewModel(authManager: AuthManager()))
}
