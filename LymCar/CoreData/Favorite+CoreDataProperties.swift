//
//  Favorite+CoreDataProperties.swift
//  LymCar
//
//  Created by 이은재 on 1/5/24.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var title: String
    @NSManaged public var subtitle: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension Favorite : Identifiable {

}
