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
    @StateObject private var viewModel: ViewModel
    @Binding var loginViewIsPresented: Bool
    @FocusState private var focusField: Field?
    @AppStorage("isFirstRun") private var isFirstRun = true
    
    init(
        isPresented: Binding<Bool>,
        authManager: AuthManagerType
    ) {
        _loginViewIsPresented = isPresented
        _viewModel = StateObject(wrappedValue: ViewModel(authManager: authManager))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Welcome!")
                    .font(.system(size: 40, weight: .heavy))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 21)
                    .foregroundStyle(.white)
                
                VStack(spacing: 0) {
                    Text("로그인")
                        .font(.system(size: 24, weight: .heavy))
                        .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                        .padding(.top, 27)
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    AuthTextField(
                        text: $viewModel.emailText,
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
                        text: $viewModel.passwordText,
                        inputType: .password,
                        height: 50,
                        isShowTitle: false
                    )
                    .padding(.top, 10)
                    .focused($focusField, equals: .password)
                    .submitLabel(.join)
                    .onSubmit {
                        viewModel.signIn()
                    }
                    
                    NavigationLink {
                        RegisterView(
                            loginViewIsPresented: $loginViewIsPresented,
                            authManager: appData.authManager
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
                    
                    RoundedActionButton(
                        label: "로그인",
                        action: {
                            viewModel.signIn()
                        }
                    )
                    .padding(.bottom, 47)
                }
                .padding(.horizontal, 21)
                .background(Color.theme.backgroundColor)
                .cornerRadius(40, corners: [.topLeft, .topRight])
                .padding(.top, 18)
                .ignoresSafeArea()
            }
            .padding(.top, 90)
            .onReceive(viewModel.$viewState) { authResult in
                switch authResult {
                case .successToNetworkRequest(let user):
                    appData.currentUser = user
                    appData.subscribeUserCarPool()
                    loginViewIsPresented.toggle()
                default:
                    break
                }
            }
            .background {
                Image("WelcomeBackgroundImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .alert(
                role: viewModel.alertRole,
                alertMessage: viewModel.alertMessage,
                isPresented: $viewModel.alertIsPresented
            )
            .loadingProgress(viewState: $viewModel.viewState)
        }
        .tint(.white)
        .fullScreenCover(isPresented: $isFirstRun, content: {
            PermissionRequestView()
        })
        
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
            locationSearchManager: LocationSearchManager(),
            messageManager: MessageManager()
        )
    )
}




