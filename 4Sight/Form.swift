//
//  Form.swift
//  4Sight
//
//  Created by Simon Withington on 04/05/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class Form: NSObject, UITableViewDelegate, UITableViewDataSource  {

    var formData: [[Dictionary<String, String>]]?
    var formCells = [IndexPath: UITableViewCell]()
    var currentSection = 0
    
    init(formDataPath: String) {
        self.formData = NSArray(contentsOfFile:formDataPath) as? [[Dictionary<String, String>]]
        super.init()
    }
    
    func mappingForIndexPath(_ indexPath: IndexPath) -> String? {
        return formData?[currentSection][(indexPath as NSIndexPath).row]["Mapping"]
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formData![currentSection].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = formCells[indexPath] {
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: (formData![currentSection][(indexPath as NSIndexPath).row]["Cell"])!)!
        formCells[indexPath] = cell
        
        if let titleLabel = cell.viewWithTag(1) as? UILabel! {
            titleLabel.text = formData?[currentSection][(indexPath as NSIndexPath).row]["Field"]
        }
        if let textField = cell.viewWithTag(2) as? UITextField {
            textField.text = formData?[currentSection][(indexPath as NSIndexPath).row]["initial"]
        }

        return cell
    }
    
    // MARK: Form Data Accessors
    
    func allEntries(tableView: UITableView) -> [(String, String, String)] {
        
        var entries = [(String, String, String)]()
        
        for row in 0..<tableView.numberOfRows(inSection: currentSection) {
            if let entry = self.tableView(tableView, entryForindexPath: IndexPath(row: row, section: currentSection)) {
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    func tableView(_ tableView: UITableView, entryForindexPath indexPath: IndexPath) -> (String, String, String)? {
        
        if let field = self.tableView(tableView, fieldForIndexPath: indexPath),
            let value = self.tableView(tableView, valueForIndexPath: indexPath),
            let mapping = mappingForIndexPath(indexPath) {
            return (field, value, mapping)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, fieldForIndexPath indexPath: IndexPath) -> String? {
        
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
            
        if let label = cell.viewWithTag(1) as? UILabel, let field = label.text {
            return field
        } else {
            return nil
        }
    }
    
    private func tableView(_ tableView: UITableView, valueForIndexPath indexPath: IndexPath) -> String? {
        
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        
        if let textField = cell.viewWithTag(2) as? UITextField, let value = textField.text {
            return value
        } else {
            return nil
        }
    }
}
