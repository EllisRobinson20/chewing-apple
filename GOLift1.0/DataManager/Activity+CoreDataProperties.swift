//
//  Activity+CoreDataProperties.swift
//  GOLift1.0
//
//  Created by L EE on 09/04/2021.
//
//

import Foundation
import CoreData


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var ability: Int16
    @NSManaged public var estTenRepsKG: Float
    @NSManaged public var exerciseName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var improvementIndex: Int16
    @NSManaged public var oneRepMax: Float

}

extension Activity : Identifiable {

}
