//
//  Feedback+CoreDataProperties.swift
//  GOLift1.0
//
//  Created by L EE on 09/04/2021.
//
//

import Foundation
import CoreData


extension Feedback {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feedback> {
        return NSFetchRequest<Feedback>(entityName: "Feedback")
    }


}

extension Feedback : Identifiable {

}
