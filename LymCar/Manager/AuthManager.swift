//
//  AuthManager.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Firebase



final class AuthManager: AuthManagerType {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func sendEmailVerification(_ email: String) async throws -> EmailVerification {
        guard let url = URL(string: "\(Constant.baseURL)/auth/email/verification/create") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        let json: [String: Any] = ["email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: json)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidServerResponse
        }
        
        return try JSONDecoder().decode(EmailVerification.self, from: data)
    }
    
    func createUser(
        withEmail email: String,
        password: String,
        gender: Gender,
        name: String
    ) async -> FirebaseNetworkResult<User>  {
        do {
            /// 회원가입 요청
            try await auth.createUser(withEmail: email, password: password)
            guard let uid = auth.currentUser?.uid else { return .failure(errorMessage: "현재 사용자의 식별값을 불러오는데 실패했습니다") }
            
            /// User 커스텀 객체 생성 및 FireStore DB에 저장
            let newUser = User(email: email, gender: gender, name: name, uid: uid)
            try db.collection("Users").document(uid).setData(from: newUser)
            
            return .success(response: newUser)
        } catch {
            /// 에러 처리
            switch error {
            case AuthErrorCode.emailAlreadyInUse:
                return .failure(errorMessage: "이미 사용중인 이메일입니다")
            case AuthErrorCode.invalidEmail:
                return .failure(errorMessage: "잘못된 이메일 형식입니다")
            case AuthErrorCode.networkError:
                return .failure(errorMessage: "네트워크 연결 상태를 확인해주세요")
            default:
                print("DEBUG: 회원가입 실패 \(error)")
                return .failure(errorMessage: "알 수 없는 오류가 발생했습니다")
            }
        }
    }
    
    func signIn(
        withEmail email: String,
        password: String
    ) async -> FirebaseNetworkResult<User> {
        do {
            /// 로그인 시도
            try await auth.signIn(withEmail: email, password: password)
            guard let uid = auth.currentUser?.uid else { return .failure(errorMessage: "현재 사용자의 식별값을 불러오는데 실패했습니다")  }
            
            /// FireStore 데이터 읽기
            let user = try await db.collection("Users").document(uid).getDocument(as: User.self)
            return .success(response: user)
        } catch {
            /// 에러 처리
            
            switch error {
            case AuthErrorCode.invalidEmail:
                return .failure(errorMessage: "잘못된 이메일 형식입니다")
            case AuthErrorCode.invalidCredential:
                return .failure(errorMessage: "이메일 또는 비밀번호 오류입니다")
            case AuthErrorCode.unverifiedEmail:
                return .failure(errorMessage: "등록되지 않은 이메일입니다")
            case AuthErrorCode.wrongPassword:
                return .failure(errorMessage: "비밀번호가 틀렸습니다")
            case AuthErrorCode.tooManyRequests:
                return .failure(errorMessage: "여러 번의 로그인 실패로 인해 계정 접근이 일시적으로 비활성화 되었습니다. 나중에 다시 시도해주세요")
            case AuthErrorCode.networkError:
                return .failure(errorMessage: "네트워크 연결 상태를 확인해주세요")
            default:
                print("DEBUG: 로그인 실패 \(error)")
                return .failure(errorMessage: "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    func checkCurrentUser() async -> User? {
        guard let uid = auth.currentUser?.uid else {
            return nil
        }
        do {
            let user = try await db.collection("Users").document(uid).getDocument(as: User.self)
            return user
        } catch {
            print("DEBUG: Fail to check current user with error \(error)")
            return nil
        }
    }
    
    @discardableResult
    func logout() -> Bool {
        do {
            try auth.signOut()
            return true
        } catch {
            return false
        }
    }
    
    func updateFcmToken(_ token: String) async {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        let docRef = db.collection("FcmTokens").document(uid)
        
        do {
            let snapshot = try await docRef.getDocument()
            
            if snapshot.exists {
                try await docRef.updateData(["token": token])
            } else {
                try await docRef.setData(["token": token, "roomIds": [String]()])
            }
        } catch {
            print("DEBUG: Fail to updateFcmToken with error \(error.localizedDescription)")
        }
    }
}

