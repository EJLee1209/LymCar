//
//  CarPoolManager.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import FirebaseFirestore
import FirebaseAuth
import CoreLocation

protocol CarPoolManagerType {
    /// 유저가 참여중인 카풀 리스트 리스너 등록
    func subscribeUserCarPool(completion: @escaping([CarPool]) -> Void)
    
    /// 카풀 리스트 가져오기
    func fetchCarPool(gender: String) async -> [CarPool]
    
    /// 카풀 생성
    func create(
        user: User,
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool>
    
    /// 카풀 참여
    func join(
        user: User,
        carPool: CarPool
    ) async -> FirebaseNetworkResult<CarPool>
    
    /// 카풀 퇴장
    func exit(
        user: User,
        roomId: String
    ) async -> FirebaseNetworkResult<String>
    
    /// 메세지 전송
    @discardableResult
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    ) -> FirebaseNetworkResult<Message>
    
    /// 새 메세지 리스너 등록
    func subscribeNewMessages(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    )
    
    /// 이전 메세지 가져오기
    func fetchMessages(
        roomId: String
    ) async -> [WrappedMessage]
    
    /// 카풀 마감
    func deactivate(roomId: String) async -> FirebaseNetworkResult<String>
    
    /// 메세지 리스너 제거
    func removeMessageListener()
    
    /// 유저 카풀 리스너 제거
    func removeUserCarPoolListener()
    
    func resetPageProperties()
}

final class CarPoolManager: CarPoolManagerType {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var messageListenerRegistration: ListenerRegistration?
    private var userCarPoolListenerRegistration: ListenerRegistration?
    
    func subscribeUserCarPool(completion: @escaping([CarPool]) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        userCarPoolListenerRegistration = db.collection("Rooms")
            .whereField("participants", arrayContains: uid)
            .order(by: "departureDate")
            .addSnapshotListener { snapshot, error in
                if let _ = error {
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                do {
                    let carPoolList = try documents.map { try $0.data(as: CarPool.self) }
                    
                    DispatchQueue.main.async {
                        completion(carPoolList)
                    }
                } catch {
                    print("DEBUG: Fail to subscribeUserCarPool with erro \(error.localizedDescription)")
                }
            }
    }
    
    func fetchCarPool(gender: String) async -> [CarPool] {
        do {
            let querySnapshot = try await db.collection("Rooms")
                .order(by: "departureDate")
                .whereField("departureDate", isGreaterThanOrEqualTo: Date())
                .whereField("genderOption", in: [gender, Gender.none.rawValue])
                .whereField("isActivate", isEqualTo: true)
                .order(by: "createdAt")
                .getDocuments()
            
            return try querySnapshot.documents
                .map { try $0.data(as: CarPool.self) }
        } catch {
            print("DEBUG: Failed to fetchCarPool with error \(error.localizedDescription)")
            return []
        }
    }
    
    func join(
        user: User,
        carPool: CarPool
    ) async -> FirebaseNetworkResult<CarPool> {
        
        if carPool.participants.contains(user.uid) { // 이미 참여중인 방
            return .success(response: carPool)
        }
        
        let roomRef = db.collection("Rooms").document(carPool.id)
        
        do {
            let transactionResult = try await db.runTransaction { transaction, errorPointer in
                let roomDocument: DocumentSnapshot
                do {
                    try roomDocument = transaction.getDocument(roomRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                if !roomDocument.exists {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "존재하지 않는 채팅방입니다"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                var room: CarPool
                do {
                    room = try roomDocument.data(as: CarPool.self)
                } catch let decodingError as NSError {
                    errorPointer?.pointee = decodingError
                    return nil
                }
                
                if room.participants.contains(user.uid) {
                    return room
                }
                
                if !room.isActivate {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "마감된 채팅방입니다"
                        ]
                    )
                    errorPointer?.pointee = error
                    
                    return nil
                }
                
                if room.personCount >= room.maxPersonCount {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "채팅방 인원이 초과됐습니다"
                        ]
                    )
                    errorPointer?.pointee = error
                    
                    return nil
                }
                
                room.personCount += 1
                room.participants.append(user.uid)
                
                let updateDict: [String: Any] = [
                    "personCount" : room.personCount,
                    "participants": room.participants
                ]
                
                transaction.updateData(
                    updateDict,
                    forDocument: roomRef
                )
                
                return room
            }
            
            let updatedCarPool = transactionResult as! CarPool
            sendMessage(sender: user, roomId: carPool.id, text: "- \(user.name) 님이 입장했습니다 -", isSystemMsg: true)
            return .success(response: updatedCarPool)
            
        } catch {
            print("DEBUG: Transaction failed with error \(error)")
            return .failure(errorMessage: error.localizedDescription)
        }
        
    }
    
    func create(
        user: User,
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool> {
        let ref = db.collection("Rooms").document()
        
        let departurePlace = Location(
            placeName: departurePlaceName,
            latitude: departurePlaceCoordinate.latitude,
            longitude: departurePlaceCoordinate.longitude
        )
        let destination = Location(
            placeName: destinationPlaceName,
            latitude: destinationCoordinate.latitude,
            longitude: destinationCoordinate.longitude
        )
        
        let carPool = CarPool(
            id: ref.documentID,
            departurePlace: departurePlace,
            destination: destination,
            departureDate: departureDate,
            genderOption: genderOption.rawValue,
            participants: [user.uid],
            maxPersonCount: maxPersonCount
        )
        
        do {
            try ref.setData(from: carPool)
            sendMessage(sender: user, roomId: carPool.id, text: "- \(user.name)님이 입장했습니다 -", isSystemMsg: true)
            return .success(response: carPool)
        } catch {
            return .failure(errorMessage: "카풀방을 생성하는데 실패했습니다. 잠시 후 다시 시도해주세요")
        }
    }
    
    func exit(
        user: User,
        roomId: String
    ) async -> FirebaseNetworkResult<String> {
        
        let roomRef = db.collection("Rooms").document(roomId)
        
        do {
            let _ = try await db.runTransaction { transaction, errorPointer in
                
                let roomDocument: DocumentSnapshot
                do {
                    try roomDocument = transaction.getDocument(roomRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                let room: CarPool
                do {
                    room = try roomDocument.data(as: CarPool.self)
                } catch let decodingError as NSError {
                    errorPointer?.pointee = decodingError
                    return nil
                }
                
                if room.personCount == 1 {
                    // 방 삭제
                    transaction.deleteDocument(roomRef)
                    
                    return nil
                }
                
                let updateDict: [String: Any] = [
                    "personCount": room.personCount - 1,
                    "participants": room.participants.filter { $0 != user.uid }
                ]
                transaction.updateData(updateDict, forDocument: roomRef)
                
                return nil
            }
            
            sendMessage(sender: user, roomId: roomId, text: "- \(user.name)님이 나갔습니다 -", isSystemMsg: true)
            return .success(response: "")
        } catch {
            return .failure(errorMessage: error.localizedDescription)
        }
        
    }
    
    
    func deactivate(roomId: String) async -> FirebaseNetworkResult<String> {
        do {
            try await db.collection("Rooms")
                .document(roomId)
                .updateData(["isActivate": false])
            
            return .success(response: "- 카풀이 마감되었습니다 -")
        } catch {
            return .failure(errorMessage: "카풀을 마감하던 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요")
        }
    }
    
    @discardableResult
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    ) -> FirebaseNetworkResult<Message> {
        let ref = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .document()
        
        let message = Message(
            id: ref.documentID,
            roomId: roomId,
            text: text,
            sender: sender,
            isSystemMsg: isSystemMsg
        )
        
        do {
            try ref.setData(from: message)
            return .success(response: message)
        } catch {
            return .failure(errorMessage: "메세지 전송 실패")
        }
    }
    
    var startDoc: DocumentSnapshot?
    var lastDoc: DocumentSnapshot?
    var endPaging: Bool = false
    
    func fetchMessages(
        roomId: String
    ) async -> [WrappedMessage] {
        if endPaging { return [] }
        guard let uid = auth.currentUser?.uid else { return [] }
        
        let commonQuery = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .order(by: "timestamp")
            .limit(toLast: 20)
        
        let requestQuery: Query
        
        if let startDoc = startDoc {
            requestQuery = commonQuery
                .end(beforeDocument: startDoc)
        } else {
            requestQuery = commonQuery
        }
        
        do {
            let snapshot = try await requestQuery.getDocuments()
            
            if snapshot.documents.isEmpty {
                endPaging = true
                print("DEBUG: 마지막 채팅 기록입니다.")
                return []
            }
            
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
            
            if wrappedMessages.count < 20 { endPaging = true }
            
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
            .order(by: "timestamp")
        
        let requestQuery: Query
        
        if let lastDoc = lastDoc {
            requestQuery = commonQuery
                .start(afterDocument: lastDoc)
        } else {
            requestQuery = commonQuery
        }
        
        requestQuery.addSnapshotListener { snapshot, error in
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
                
                completion(wrappedMessages)
            } catch {
                print("DEBUG: Fail to subscribeNewMessages with error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func resetPageProperties() {
        endPaging = false
        startDoc = nil
        lastDoc = nil
    }
    
    func removeMessageListener() {
        messageListenerRegistration?.remove()
    }
    
    func removeUserCarPoolListener() {
        userCarPoolListenerRegistration?.remove()
    }
}
