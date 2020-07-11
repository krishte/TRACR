//
//  Subassignment+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/11/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension Subassignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subassignment> {
        return NSFetchRequest<Subassignment>(entityName: "Subassignment")
    }

    @NSManaged public var assigmentname: String
    @NSManaged public var enddatetime: String
    @NSManaged public var startdatetime: String

}
