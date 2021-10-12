//
//  ToDoListTableViewController.swift
//  Todoey
//
//  Created by Shirayo on 05.10.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import SwiftUI

class ToDoListTableViewController: SwipeCellTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var currentCategory: Category? {
        didSet {
            loadItems()
        }
    }
    var items: Results<Item>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = .blue
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setAppearance()
    }
    
    func setAppearance() {
        if let hexColor = currentCategory?.color {
            guard let color = UIColor(hexString: hexColor) else {fatalError()}
            guard let navBar = navigationController?.navigationBar else { return }
            title = currentCategory?.name
            searchBar.barTintColor = color
            searchBar.searchTextField.backgroundColor = .white
            navBar.tintColor = ContrastColorOf(color, returnFlat: true)
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = color
            barAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(color, returnFlat: true)]
            barAppearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(color, returnFlat: true)]
            navigationItem.standardAppearance = barAppearance
            navigationItem.scrollEdgeAppearance = barAppearance
        }
    }
    
    //MARK: - data manipulation functions
    
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    realm.delete(item)
                })
            } catch {
                print("error deleting category: \(error)")
            }
        }
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark: .none
            if let color = UIColor(hexString: currentCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                cell.backgroundColor = color
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
           
        } else {
            cell.textLabel?.text = "no items created yet"
        }
        
        return cell
    }

}

//MARK: -extensions

extension ToDoListTableViewController: UISearchBarDelegate {
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        loadItems()
//        searchBar.resignFirstResponder()
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadItems()
        guard searchBar.text?.count != 0 else {return}
        let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        items = items?.filter(filterPredicate).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
}
