//
//  ToDoListTableViewController.swift
//  Todoey
//
//  Created by Shirayo on 05.10.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListTableViewController: UITableViewController {

    var currentCategory: Category? {
        didSet {
            loadItems()
        }
    }
    var items: Results<Item>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
       
    }
    
    func loadItems() {
        if let selectedCategory = currentCategory {
            items = selectedCategory.items.sorted(byKeyPath: "date", ascending: false)
        }
    
        self.tableView.reloadData()
    
    }
    
    func save(item: Item) {
        do {
            try realm.write({
                realm.add(item)
            })
        } catch {
            print("error adding new item: \(error)")
        }
        tableView.reloadData()
    }
    //MARK: - create new item
    
    
    @IBAction func addNewItemButtonDidClick(_ sender: UIBarButtonItem) {
        var enteredText = UITextField()
        let alert = UIAlertController(title: nil, message: "Add new item", preferredStyle: .alert)
        alert.addTextField { textfield in
            enteredText  = textfield
        }
        let action = UIAlertAction(title: "add", style: .default) { UIAlertAction in
            guard enteredText.text != "" else {return}
            guard let currentCategory = self.currentCategory else {return}
            do {
                try self.realm.write({
                    let newItem = Item()
                    newItem.title = enteredText.text!
                    currentCategory.items.append(newItem)
                })
                
            } catch {
                
            }
            
            self.tableView.reloadData()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    item.isDone.toggle()
                })
            } catch {
                print("error updating item \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            do {
                try realm.write({
                    realm.delete(items![indexPath.row])
                })
            } catch {
                print("error deleting item \(error)")
            }
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark: .none
        } else {
            cell.textLabel?.text = "no items created yet"
        }
        
        return cell
    }

}
