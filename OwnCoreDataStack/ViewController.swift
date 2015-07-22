//
//  ViewController.swift
//  OwnCoreDataStack
//
//  Created by Lynch Wong on 7/22/15.
//  Copyright (c) 2015 Nobodyknows. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    var managedContext: NSManagedObjectContext!
    
    var currentWarehouse: Warehouse!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let warehouseEntity = NSEntityDescription.entityForName("Warehouse", inManagedObjectContext: managedContext)!
        
        let warehouseName = "L"
        let fetchRequest = NSFetchRequest(entityName: "Warehouse")
        fetchRequest.predicate = NSPredicate(format: "name == %@", warehouseName)
        
        var error: NSError?
        let result = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [Warehouse]
        if let warehouses = result {
            if warehouses.count == 0 {
                currentWarehouse = Warehouse(entity: warehouseEntity, insertIntoManagedObjectContext: managedContext)
                currentWarehouse.name = warehouseName
                
                if !managedContext.save(&error) {
                    println("Could not save: \(error)")
                }
            } else {
                currentWarehouse = warehouses[0]
            }
        } else {
            println("Could not fetch: \(error)")
        }
        
        navigationItem.title = currentWarehouse.name
    }

    @IBAction func add(sender: AnyObject) {
        var alert = UIAlertController(title: "添加仓库", message: "输入仓库名", preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "保存", style: .Default) {
            (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as! UITextField
            self.saveName(textField.text)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .Default) {
            (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveName(name: String) {
        let entity = NSEntityDescription.entityForName("Good", inManagedObjectContext: managedContext)!
        let good = Good(entity: entity, insertIntoManagedObjectContext: managedContext)
        good.name = name
        
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
            let goodRemove = currentWarehouse.goods[indexPath.row] as! Good
            let goods = currentWarehouse.goods.mutableCopy() as! NSMutableOrderedSet
            goods.removeObjectAtIndex(indexPath.row)
            currentWarehouse.goods = goods.copy() as! NSOrderedSet
            
            managedContext.deleteObject(goodRemove)
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save: \(error)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        if let warehouse = currentWarehouse {
            numRows = warehouse.goods.count
        }
        return numRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        let good = currentWarehouse.goods[indexPath.row] as! Good
        cell?.textLabel?.text = good.name
        return cell!
    }
    
    

}

