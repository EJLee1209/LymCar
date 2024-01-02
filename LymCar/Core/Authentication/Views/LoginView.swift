//
//  LoginView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct LoginView: View {
    enum Field: Hashable {
        case email, password
    }
    
    @EnvironmentObject private var appData: AppData
    @StateObject private var viewModel: AuthViewModel
    @Binding var loginViewIsPresented: Bool
    
    @AppStorage("email") private var emailText: String = ""
    @State private var passwordText: String = ""
    @FocusState private var focusField: Field?
    
    init(
        isPresented: Binding<Bool>,
        authManager: AuthManagerType
    ) {
        _loginViewIsPresented = isPresented
        _viewModel = StateObject(wrappedValue: AuthViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Welcome!")
                    .font(.system(size: 40, weight: .heavy))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 21)
                    .foregroundStyle(.white)
                
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
                    .focused($focusField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusField = .password
                    }
                    
                    AuthTextField(
                        text: $passwordText,
                        inputType: .password,
                        height: 50,
                        isShowTitle: false
                    )
                    .padding(.top, 10)
                    .focused($focusField, equals: .password)
                    .submitLabel(.join)
                    .onSubmit {
                        viewModel.signIn(withEmail: emailText, password: passwordText)
                    }
                    
                    NavigationLink {
                        RegisterView(
                            viewModel: viewModel,
                            loginViewIsPresented: $loginViewIsPresented
                        )
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
            .padding(.top, 100)
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
                    appData.currentUser = user
                    appData.fetchUserCarPool()
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
    LoginView(
        isPresented: .constant(true),
        authManager: AuthManager()
    )
    .environmentObject(
        AppData(
            authManager: AuthManager(),
            carPoolManager: CarPoolManager(),
            locationSearchManager: LocationSearchManager()
        )
    )
}




