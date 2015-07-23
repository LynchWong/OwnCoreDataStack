//
//  ViewController.swift
//  OwnCoreDataStack
//
//  Created by Lynch Wong on 7/22/15.
//  Copyright (c) 2015 Nobodyknows. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var managedContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var psc: NSPersistentStoreCoordinator!
    
    var currentWarehouse: Warehouse!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let warehouseEntity = NSEntityDescription.entityForName("Warehouse", inManagedObjectContext: managedContext)!
//        
//        let warehouseName = "L"
//        let fetchRequest = NSFetchRequest(entityName: "Warehouse")
//        fetchRequest.predicate = NSPredicate(format: "name == %@", warehouseName)
//        
//        var error: NSError?
//        let result = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [Warehouse]
//        if let warehouses = result {
//            if warehouses.count == 0 {
//                currentWarehouse = Warehouse(entity: warehouseEntity, insertIntoManagedObjectContext: managedContext)
//                currentWarehouse.name = warehouseName
//                
//                if !managedContext.save(&error) {
//                    println("Could not save: \(error)")
//                }
//            } else {
//                currentWarehouse = warehouses[0]
//            }
//        } else {
//            println("Could not fetch: \(error)")
//        }
//        
//        navigationItem.title = currentWarehouse.name
        
        navigationItem.title = "商品"
        
        let fetchRequest = NSFetchRequest(entityName: "Good")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: "category", cacheName: "")
        fetchedResultsController.delegate = self
        
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            println("Error: \(error?.localizedDescription)")
        }
    }

    @IBAction func add(sender: AnyObject) {
//        var alert = UIAlertController(title: "添加仓库", message: "输入仓库名", preferredStyle: .Alert)
//        let saveAction = UIAlertAction(title: "保存", style: .Default) {
//            (action: UIAlertAction!) -> Void in
//            let textField = alert.textFields![0] as! UITextField
//            self.saveName(textField.text)
//            self.tableView.reloadData()
//        }
//        let cancelAction = UIAlertAction(title: "取消", style: .Default) {
//            (action: UIAlertAction!) -> Void in
//        }
//        
//        alert.addTextFieldWithConfigurationHandler {
//            (textField: UITextField!) -> Void in
//        }
//        
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        
//        presentViewController(alert, animated: true, completion: nil)
        
        var alert = UIAlertController(title: "添加商品", message: "新增商品", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "名字"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "数量"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) in
            textField.placeholder = "类型"
        }
        
        alert.addAction(UIAlertAction(title: "保存", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
                let nameTextField = alert.textFields![0] as! UITextField
                let numberTextField = alert.textFields![1] as! UITextField
                let categoryTextField = alert.textFields![2] as! UITextField
            
                let entity = NSEntityDescription.entityForName("Good", inManagedObjectContext: self.managedContext)!
                let good = Good(entity: entity, insertIntoManagedObjectContext: self.managedContext)
                good.name = nameTextField.text
                good.number = NSNumber(int: Int32(NSString(string: numberTextField.text).integerValue))
                good.category = categoryTextField.text
                
                self.managedContext.save(nil)
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
                println("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveName(name: String) {
        let entity = NSEntityDescription.entityForName("Good", inManagedObjectContext: managedContext)!
        let good = Good(entity: entity, insertIntoManagedObjectContext: managedContext)
        good.name = name
        good.price = NSNumber(double: 100)
        good.category = "蔬菜"
        good.number = NSNumber(int: 10)
        
        var goods = currentWarehouse.goods.mutableCopy() as! NSMutableOrderedSet
        goods.addObject(good)
        
        currentWarehouse.goods = goods.copy() as! NSOrderedSet
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let good = fetchedResultsController.objectAtIndexPath(indexPath) as! Good
            managedContext.deleteObject(good)
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save: \(error)")
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        let good = fetchedResultsController.objectAtIndexPath(indexPath) as! Good
        cell?.textLabel?.text = "\(good.name) - 数量：\(good.number)"
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let good = fetchedResultsController.objectAtIndexPath(indexPath) as! Good
        let number = good.number.integerValue
        good.number = NSNumber(int: number + 1)

        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save: \(error)")
        }
        tableView.reloadData()
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            case .Update:
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            default:
                break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
                    
        let indexSet = NSIndexSet(index: sectionIndex)
                    
        switch type {
            case .Insert:
                tableView.insertSections(indexSet, withRowAnimation: .Automatic)
            case .Delete:
                tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
            default :
                break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            addButton.enabled = true
        }
    }

}

