//
//  MessageManager.swift
//  LymCar
//
//  Created by 이은재 on 1/3/24.
//

import Foundation
import Firebase


final class MessageManager: MessageManagerType {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var startDoc: DocumentSnapshot?
    private var lastDoc: DocumentSnapshot?
    private var endPaging: Bool = false
    private var limit: Int = 20
    
    private var messageListenerRegistration: ListenerRegistration?
    
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    ) {
        /// 채팅방에 참여 중인 사용자의 fcmToken 값을 가져와서 push 전송
        Task {
            let tokens = await getParticipantsTokens(roomId: roomId)
            
            for token in tokens {
                let pushMessage = PushMessage(
                    fcmToken: token,
                    roomId: roomId,
                    from: sender.name,
                    msg: text
                )
                await sendPush(pushMessage)
            }
        }
        
        /// Firestore DB 에 저장
        let docRef = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .document()
        
        docRef.setData([
            "id": docRef.documentID,
            "roomId": roomId,
            "text": text,
            "sender": sender.toDict,
            "isSystemMsg": isSystemMsg,
            "timestamp": FieldValue.serverTimestamp()
        ])

    }
    
    private func sendPush(_ pushMessage: PushMessage) async {
        guard let url = URL(string: "\(Constant.baseURL)/push") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        do {
            request.httpBody = try JSONEncoder().encode(pushMessage)
        } catch {
            print("DEBUG: Unable to convert PushMessage to JSON")
        }
        
        do {
            _ = try await URLSession.shared.data(for: request)
        } catch {
            print("DEBUG: Fail to sendPush with error \(error.localizedDescription)")
        }
    }
    
    func fetchMessages(
        roomId: String
    ) async -> [WrappedMessage] {
        if endPaging { return [] }
        guard let uid = auth.currentUser?.uid else { return [] }
        
        var timestamp = Timestamp()
        do {
            timestamp = try await getJoinTimeStamp(roomId: roomId)
        } catch {
            print("DEBUG: fail to getJoinTimeStamp with error \(error.localizedDescription)")
        }
        
        let commonQuery = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .order(by: "timestamp") // timestamp 필드를 기준으로 오름차순 정렬
            .whereField("timestamp", isGreaterThanOrEqualTo: timestamp)
            .limit(toLast: limit) // 마지막에서 20개
        
        let requestQuery: Query
        
        /// 이전 페이지의 첫번재 Document가 있는지 확인
        if let startDoc = startDoc {
            /// 다음 페이지 = 이전 페이지의 첫번째 Document 이전까지의 20개
            requestQuery = commonQuery
                .end(beforeDocument: startDoc)
        } else {
            requestQuery = commonQuery
        }
        
        do {
            let snapshot = try await requestQuery.getDocuments()
            
            /// document가 비어있다면, 더 이상 다음 페이지는 존재하지 않음.
            /// 이후 쿼리 요청을 막기 위해서 Bool 타입 flag 변수 사용
            if snapshot.documents.isEmpty {
                endPaging = true
                return []
            }
            
            /// 현재 페이지의 첫번째 Document와 마지막 Document를 기록
            /// startDoc은 다음 페이지의 마지막 Document를 지정하기 위해서 사용
            /// lastDoc은 새로운 메세지를 구독하는 시작 Document를 지정하기 위해서 사용
            startDoc = snapshot.documents.first
            lastDoc = snapshot.documents.last
            
            
            let wrappedMessages = try snapshot.documents.map { document -> WrappedMessage in
                let message = try document.data(as: Message.self)
                if message.isSystemMsg {
                    return .system(message: message)
                } else if message.sender.uid == uid {
                    return .currentUser(message: message)
                } else {
                    return .otherUser(message: message)
                }
            }
            
            /// 만약 20개(페이지 Document 수) 보다 작다면, 마지막 페이지임
            if wrappedMessages.count < limit { endPaging = true }
            
            return wrappedMessages
        } catch {
            print("DEBUG: Fail to subscribeNewMessages with error: \(error.localizedDescription)")
            return []
        }
    }
    
    func subscribeNewMessages(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    ) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let commonQuery = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .order(by: "timestamp") // timestamp를 기준으로 오름차순 정렬
        
        let requestQuery: Query
        
        /// 첫번째 페이지의 마지막 Document(구독의 시작 지점)를 가져옴
        if let lastDoc = lastDoc {
            /// lastDoc 이후의  Query
            requestQuery = commonQuery
                .start(afterDocument: lastDoc)
        } else {
            requestQuery = commonQuery
        }
        
        messageListenerRegistration?.remove()
        
        messageListenerRegistration = requestQuery.addSnapshotListener { snapshot, error in
            guard let document = snapshot?.documents else {
                print("DEBUG: Fail to subscribeNewMessages with error document is nil")
                return
            }
            
            do {
                let wrappedMessages = try document
                    .map { document -> WrappedMessage in
                        let message = try document.data(as: Message.self)
                        if message.isSystemMsg {
                            return .system(message: message)
                        } else if message.sender.uid == uid {
                            return .currentUser(message: message)
                        } else {
                            return .otherUser(message: message)
                        }
                    }
                
                DispatchQueue.main.async {
                    completion(wrappedMessages)
                }
                print("DEBUG: new message!")
            } catch {
                print("DEBUG: Fail to subscribeNewMessages with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func getParticipantsTokens(roomId: String) async -> [String] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        var tokens: [String] = []
        
        do {
            let snapshot = try await db.collection("FcmTokens")
                .whereField(.documentID(), isNotEqualTo: uid)
                .whereField("roomIds", arrayContains: roomId)
                .getDocuments()
            
            snapshot.documents.forEach { document in
                let data = document.data()
                let token = data["token"] as! String
                tokens.append(token)
            }
            
            return tokens
        } catch {
            print("DEBUG: Fail to getParticipantsTokens with error \(error.localizedDescription)")
            return []
        }
    }
    
    private func getJoinTimeStamp(roomId: String) async throws -> Timestamp {
        guard let uid = auth.currentUser?.uid else {
            throw AuthErrorCode(.nullUser)
        }
        
        let document = try await db.collection("Rooms")
            .document(roomId)
            .collection("joinTimeStamp")
            .document(uid)
            .getDocument()
        
        guard let data = document.data() else {
            throw FirestoreErrorCode(.dataLoss)
        }
        
        let timestamp = data["timestamp"] as! Timestamp
        return timestamp
    }
    
    func resetPageProperties() {
        endPaging = false
        startDoc = nil
        lastDoc = nil
    }
    
}
