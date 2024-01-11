//
//  CarPoolManager.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import FirebaseFirestore
import FirebaseAuth
import CoreLocation

final class CarPoolManager: CarPoolManagerType {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var userCarPoolListenerRegistration: ListenerRegistration?
    private var carPoolListenerRegistration: ListenerRegistration?
    
    func subscribeUserCarPool(completion: @escaping([CarPool]) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        userCarPoolListenerRegistration?.remove()
        
        userCarPoolListenerRegistration = db.collection("Rooms")
            .whereField("participants", arrayContains: uid)
            .order(by: "departureDate")
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    guard let documents = snapshot?.documents else {
                        return
                    }
                    
                    do {
                        let carPoolList = try documents.map { try $0.data(as: CarPool.self) }
                        completion(carPoolList)
                        print("DEBUG: user car pool!")
                    } catch {
                        print("DEBUG: Fail to subscribeUserCarPool with erro \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func subscribeCarPool(roomId: String, completion: @escaping (FirebaseNetworkResult<CarPool>) -> Void) {
        carPoolListenerRegistration?.remove()
        
        carPoolListenerRegistration = db.collection("Rooms")
            .whereField("id", isEqualTo: roomId)
            .addSnapshotListener({ snapshot, error in
                DispatchQueue.main.async {
                    guard let document = snapshot?.documents.first else {
                        completion(.failure(errorMessage: "존재하지 않는 채팅방입니다"))
                        return
                    }
                    
                    do {
                        let carPool = try document.data(as: CarPool.self)
                        completion(.success(response: carPool))
                    } catch {
                        completion(.failure(errorMessage: error.localizedDescription))
                    }
                }
            })
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
            
            Task {
                var roomIds = await getUserCarPoolIds()
                roomIds.append(carPool.id)
                try await db.collection("FcmTokens").document(user.uid).updateData(["roomIds": roomIds])
            }
            
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
            
            Task {
                var roomIds = await getUserCarPoolIds()
                roomIds.append(carPool.id)
                try await db.collection("FcmTokens").document(user.uid).updateData(["roomIds": roomIds])
            }
            
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
            
            let roomIds = await getUserCarPoolIds()
            let newRoomIds = roomIds.filter { $0 != roomId }
            try await db.collection("FcmTokens").document(user.uid).updateData(["roomIds": newRoomIds])
            
            return .success(response: "")
        } catch {
            return .failure(errorMessage: error.localizedDescription)
        }
        
    }
    
    private func getUserCarPoolIds() async -> [String] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        do {
            let snapshot = try await db.collection("FcmTokens").document(uid).getDocument()
            
            guard let data = snapshot.data() else {
                return []
            }
            let roomIds = data["roomIds"] as! [String]
            
            return roomIds
        } catch {
            print("DEBUG: Fail to getUserCarPoolIds with error \(error.localizedDescription)")
            
            return []
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
}
