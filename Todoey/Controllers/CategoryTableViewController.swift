//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    var categories: Results<Category>?
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
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
    }
    
    
    //MARK: tableview methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "no categories created yet"
        return cell
    }
}

