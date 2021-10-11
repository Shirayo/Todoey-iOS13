//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: SwipeCellTableViewController {
    
    var categories: Results<Category>?
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 70
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    @IBAction func addCategoryButtonDidClick(_ sender: UIBarButtonItem) {
        var enteredText = UITextField()
        let alert = UIAlertController(title: nil, message: "Add new category", preferredStyle: .alert)
        alert.addTextField { textfield in
            enteredText  = textfield
        }
        let action = UIAlertAction(title: "add", style: .default) { UIAlertAction in
            let newCategory = Category()
            newCategory.name = enteredText.text!
            self.save(category: newCategory)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error saving category: \(error)")
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVS = segue.destination as! ToDoListTableViewController
            if let indexpath = tableView.indexPathForSelectedRow {
                destinationVS.currentCategory = categories?[indexpath.row]
            }
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write({
                    for item in category.items {
                        realm.delete(item)
                    }
                    realm.delete(category)
                })
            } catch {
                print("error deleting category: \(error)")
            }
        }
        
    }
    
    //MARK: tableview methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "no categories created yet"
        return cell
    }
    
}

