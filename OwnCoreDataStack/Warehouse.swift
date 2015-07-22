//
//  Warehouse.swift
//  OwnCoreDataStack
//
//  Created by Lynch Wong on 7/22/15.
//  Copyright (c) 2015 Nobodyknows. All rights reserved.
//

import Foundation
import CoreData

class Warehouse: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var goods: NSOrderedSet

}
