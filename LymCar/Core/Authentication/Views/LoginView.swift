//
//  LoginView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct LoginView: View {
    /// AuthViewModel을 LoginView에서 생성해서 AuthViewModel의 생명주기를 LoginView에 종속시킨다.
    /// 로그인 또는 회원가입이 완료되어서 LoginView가 dismiss된다면, AuthViewModel 또한 메모리에서 제거된다.
    @StateObject var viewModel: AuthViewModel = .init(authManager: AuthManager())
    @EnvironmentObject var userViewModel: UserViewModel
    
    @AppStorage("email") var emailText: String = ""
    @State var passwordText: String = ""
    @Binding var loginViewIsPresented: Bool
    
    var body: some View {
        NavigationView {
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
                        RegisterView(loginViewIsPresented: $loginViewIsPresented)
                            .environmentObject(viewModel)
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
                viewModel.alertMessage,
                isPresented: $viewModel.alertIsPresented
            ) {
                Button {
                    viewModel.viewState = .none
                } label: {
                    Text("확인")
                        .font(.system(size: 15))
                }
            }
            .onReceive(viewModel.$viewState) { authResult in
                switch authResult {
                case .successToNetworkRequest(let user):
                    userViewModel.currentUser = user
                    loginViewIsPresented.toggle()
                default:
                    break
                }
            }
            .loadingProgress(viewState: $viewModel.viewState)
        }
    }
}

#Preview {
    LoginView(loginViewIsPresented: .constant(false))
        .environmentObject(UserViewModel(authManager: AuthManager()))
}




