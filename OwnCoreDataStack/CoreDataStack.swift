//
//  CoreDataStack.swift
//  OwnCoreDataStack
//
//  Created by Lynch Wong on 7/22/15.
//  Copyright (c) 2015 Nobodyknows. All rights reserved.
//

import CoreData

class CoreDataStack {
    let context: NSManagedObjectContext
    let psc: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    var store: NSPersistentStore?
    
    init() {
        //1
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("Model", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        //2
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //3
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        
        //4
        let documentsURL = applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("Model")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        var error: NSError?
        store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil,
            URL: storeURL, options: options, error: &error)
        
        if store == nil {
            println("Error adding persistent store: \(error)")
            abort()
        }
    }
    
    func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as! [NSURL]
        return urls[0]
    }
    
    func saveContext() {
        var error: NSError?
        if context.hasChanges && !context.save(&error) {
            println("Could not save: \(error), \(error?.userInfo)")
        }
    }
}
