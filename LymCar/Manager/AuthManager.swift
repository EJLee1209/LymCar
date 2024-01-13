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
    
    private var deviceIdListener: ListenerRegistration?
    
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
    ) async throws -> User {
        /// 이메일, 패스워드 회원가입 요청
        try await auth.createUser(withEmail: email, password: password)
        guard let uid = auth.currentUser?.uid else {
            try await auth.currentUser?.delete()
            
            throw AuthErrorCode(.nullUser)
        }
        
        /// User 커스텀 객체 생성 및 FireStore DB에 저장
        let newUser = User(email: email, gender: gender, name: name, uid: uid)
        try db.collection("Users").document(uid).setData(from: newUser)

        
        return newUser
    }
    
    func signIn(
        withEmail email: String,
        password: String
    ) async throws -> User {
        /// 로그인 시도
        try await auth.signIn(withEmail: email, password: password)
        guard let uid = auth.currentUser?.uid else {
            throw AuthErrorCode(.nullUser)
        }
        
        /// FireStore 데이터 읽기
        let user = try await db.collection("Users").document(uid).getDocument(as: User.self)
        return user
    }
    
    func checkCurrentUser() async throws -> User? {
        guard let uid = auth.currentUser?.uid else {
            return nil
        }
        
        let user = try await db.collection("Users").document(uid).getDocument(as: User.self)
        return user
    }
    
    
    func logout() throws {
        guard let uid = auth.currentUser?.uid else {
            throw AuthErrorCode(.nullUser)
        }
        
        db.collection("FcmTokens")
            .document(uid)
            .updateData(["token": ""])
        
        try auth.signOut()
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
    
    func deleteUser(email: String, password: String) async throws {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        
        async let _ = db.collection("Users")
            .document(authResult.user.uid)
            .delete()
        async let _ = db.collection("FcmTokens")
            .document(authResult.user.uid)
            .delete()
        
        try await authResult.user.delete()
    }
}

