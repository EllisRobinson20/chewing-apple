//
//  History+CoreDataProperties.swift
//  GOLift1.0
//
//  Created by L EE on 09/04/2021.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var exerciseName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var repsAchieved: NSObject?
    @NSManaged public var targetName: String?
    @NSManaged public var weightsAchieved: NSObject?

}

extension History : Identifiable {

}
