//
//  ExerciseState+CoreDataProperties.swift
//  GOLift1.0
//
//  Created by L EE on 09/04/2021.
//
//

import Foundation
import CoreData


extension ExerciseState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseState> {
        return NSFetchRequest<ExerciseState>(entityName: "ExerciseState")
    }

    @NSManaged public var id: Int16
    @NSManaged public var isAdded: Bool
    @NSManaged public var name: String?

}

extension ExerciseState : Identifiable {

}
