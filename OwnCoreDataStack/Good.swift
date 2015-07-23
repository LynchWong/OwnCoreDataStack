//
//  Good.swift
//  OwnCoreDataStack
//
//  Created by Lynch Wong on 7/23/15.
//  Copyright (c) 2015 Nobodyknows. All rights reserved.
//

import Foundation
import CoreData

class Good: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var price: NSNumber
    @NSManaged var category: String
    @NSManaged var number: NSNumber
    @NSManaged var warehouse: Warehouse

}
