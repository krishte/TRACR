//
//  Freetime+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/19/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension Freetime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Freetime> {
        return NSFetchRequest<Freetime>(entityName: "Freetime")
    }

    @NSManaged public var startdatetime: Date
    @NSManaged public var enddatetime: Date
    @NSManaged public var weekrepeat: Bool
    @NSManaged public var dayrepeat: Bool

}
