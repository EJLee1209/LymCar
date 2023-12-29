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
    func fetchMyCarPool() async -> [CarPool]
    
    func fetchCarPool(gender: String) async -> [CarPool]
    
    func createCarPool(
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool>
    
    func joinCarPool(
        user: User,
        carPool: CarPool
    ) async -> FirebaseNetworkResult<CarPool>
    
    @discardableResult
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    ) -> FirebaseNetworkResult<Message>
    
    func fetchMessageListener(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    )
}

final class CarPoolManager: CarPoolManagerType {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func fetchMyCarPool() async -> [CarPool] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        do {
            let querySnapshot = try await db.collection("Rooms")
                .whereField("participants", arrayContains: uid)
                .getDocuments()
            
            let carPoolList = try querySnapshot.documents.map { try $0.data(as: CarPool.self) }
            return carPoolList
        } catch {
            print("DEBUG: Failed to fetchMyCarPool with error \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchCarPool(gender: String) async -> [CarPool] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
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
    
    func joinCarPool(
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
    
    func createCarPool(
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
        
        db.collection("Rooms")
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
                    completion(messageList)
                } catch {
                    print("DEBUG: fetchMessage 디코딩 에러")
                }
            }
    }
}
