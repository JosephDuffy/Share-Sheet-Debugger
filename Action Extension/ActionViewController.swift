//
//  ActionViewController.swift
//  Action Extension
//
//  Created by Joseph Duffy on 26/02/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import MobileCoreServices

let ShowItemProviderDetailSegue = "ShowItemProviderDetail"

class ActionViewController: UITableViewController {

    private(set) var items: [NSExtensionItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ItemProviderTableViewCell.self, forCellReuseIdentifier: ItemProviderTableViewCell.resuseIdentifier)

        guard let extensionContext = extensionContext else {
            let alert = UIAlertController(title: "Error", message: "Extension context shouldn't be nil", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            return
        }

        guard let inputItems = extensionContext.inputItems as? [NSExtensionItem] else {
            let alert = UIAlertController(title: "Error", message: "Failed to cast input items to [NSExtensionItem]", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            return
        }

        for (itemIndex, inputItem) in inputItems.enumerated() {
            items.append(inputItem)

            tableView.beginUpdates()

            tableView.insertSections(NSIndexSet(index: itemIndex) as IndexSet, with: .automatic)

            if let itemProviders = inputItem.attachments {
                for itemIndex in 0..<itemProviders.count {
                    tableView.insertRows(at: [IndexPath(row: itemIndex, section: itemIndex)], with: .automatic)
                }
            } else {
                tableView.insertRows(at: [IndexPath(row: 0, section: itemIndex)], with: .automatic)
            }

            tableView.endUpdates()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items[section].attachments)?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]

        if let itemProviders = item.attachments, itemProviders.count > indexPath.row {
            let itemProvider = itemProviders[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: ItemProviderTableViewCell.resuseIdentifier, for: indexPath) as! ItemProviderTableViewCell

            cell.itemProvider = itemProvider
            
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Error loading item attachements"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = items[section]

        return item.attributedTitle?.string ?? "Item \(section + 1)"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowItemProviderDetailSegue, sender: tableView.cellForRow(at: indexPath as IndexPath))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowItemProviderDetailSegue {
            guard let cell = sender as? ItemProviderTableViewCell else { return }
            guard let itemProvider = cell.itemProvider else { return }
            guard let tableViewController = segue.destination as? ItemProviderTableViewController else { return }

            let dataSource = ItemProviderTableViewDataSource(itemProvider: itemProvider)
            tableViewController.dataSource = dataSource
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
