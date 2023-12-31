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
    func fetchUserCarPoolListener(completion: @escaping([CarPool]) -> Void)
    
    /// 카풀 리스트 가져오기
    func fetchCarPool(gender: String) async -> [CarPool]
    
    /// 카풀 생성
    func create(
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
    
    /// 메세지 리스너 등록
    func fetchMessageListener(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    )
    
    // 메세지 리스너 제거
    func removeMessageListener()
    
    /// 카풀 마감
    func deactivate(roomId: String) async -> FirebaseNetworkResult<String>
    
}

final class CarPoolManager: CarPoolManagerType {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var messageListenerRegistration: ListenerRegistration?
    
    func fetchUserCarPoolListener(completion: @escaping([CarPool]) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion([])
            return
        }
        
        db.collection("Rooms")
            .whereField("participants", arrayContains: uid)
            .order(by: "departureDate")
            .addSnapshotListener { snapshot, error in
                if let _ = error {
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                do {
                    let carPoolList = try documents.map { try $0.data(as: CarPool.self) }
                    completion(carPoolList)
                } catch {
                    completion([])
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
                
                let updateDict: [String: Any] = [
                    "personCount" : room.personCount + 1,
                    "participants": room.participants + [user.uid]
                ]
                
                transaction.updateData(
                    updateDict,
                    forDocument: roomRef
                )
                
                return nil
            }
            
            do {
                let carPool = try await roomRef.getDocument(as: CarPool.self)
                sendMessage(sender: user, roomId: carPool.id, text: "- \(user.name)님이 입장했습니다 -", isSystemMsg: true)
                
                return .success(response: carPool)
            } catch {
                return .failure(errorMessage: "카풀 정보를 가져오지 못했습니다")
            }
            
        } catch {
            print("DEBUG: Transaction failed with error \(error)")
            return .failure(errorMessage: error.localizedDescription)
        }
        
    }
    
    func create(
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool> {
        guard let uid = auth.currentUser?.uid else { return .failure(errorMessage: "사용자 정보를 가져오지 못했습니다") }
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
            participants: [uid],
            maxPersonCount: maxPersonCount
        )
        
        do {
            try ref.setData(from: carPool)
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
            .collection("Messages")
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
    
    func fetchMessageListener(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    ) {
        guard let uid = auth.currentUser?.uid else { return }
        
        messageListenerRegistration = db.collection("Rooms")
            .document(roomId)
            .collection("Messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("DEBUG: Fail to fetchMessage with error \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    return
                }
                
                do {
                    let messageList = try documents
                        .map { try $0.data(as: Message.self) }
                        .map { message -> WrappedMessage in
                            if message.isSystemMsg {
                                return .system(message: message)
                            }
                            if message.sender.uid == uid {
                                return .currentUser(message: message)
                            }
                            
                            return .otherUser(message: message)
                        }
                    print("DEBUG: fetch message List")
                    completion(messageList)
                } catch {
                    print("DEBUG: fetchMessage 디코딩 에러")
                }
            }
        
    }
    
    func removeMessageListener() {
        messageListenerRegistration?.remove()
    }
    
    
}
