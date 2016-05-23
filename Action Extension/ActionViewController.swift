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

        tableView.registerClass(ItemProviderTableViewCell.self, forCellReuseIdentifier: ItemProviderTableViewCell.resuseIdentifier)

        guard let extensionContext = extensionContext else {
            let alert = UIAlertController(title: "Error", message: "Extension context shouldn't be nil", preferredStyle: .Alert)
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        guard let inputItems = extensionContext.inputItems as? [NSExtensionItem] else {
            let alert = UIAlertController(title: "Error", message: "Failed to cast input items to [NSExtensionItem]", preferredStyle: .Alert)
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        for (itemIndex, inputItem) in inputItems.enumerate() {
            items.append(inputItem)

            tableView.beginUpdates()

            tableView.insertSections(NSIndexSet(index: itemIndex), withRowAnimation: .Automatic)

            if let itemProviders = inputItem.attachments as? [NSItemProvider] {
                for itemIndex in 0..<itemProviders.count {
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: itemIndex, inSection: itemIndex)], withRowAnimation: .Automatic)
                }
            } else {
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: itemIndex)], withRowAnimation: .Automatic)
            }

            tableView.endUpdates()
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items[section].attachments as? [NSItemProvider])?.count ?? 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.section]

        if let itemProviders = item.attachments as? [NSItemProvider] where itemProviders.count > indexPath.row {
            let itemProvider = itemProviders[indexPath.row]

            let cell = tableView.dequeueReusableCellWithIdentifier(ItemProviderTableViewCell.resuseIdentifier, forIndexPath: indexPath) as! ItemProviderTableViewCell

            cell.itemProvider = itemProvider
            
            return cell
        } else {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.text = "Error loading item attachements"
            return cell
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = items[section]

        return item.attributedTitle?.string ?? "Item \(section + 1)"
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(ShowItemProviderDetailSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShowItemProviderDetailSegue {
            guard let cell = sender as? ItemProviderTableViewCell else { return }
            guard let itemProvider = cell.itemProvider else { return }
            guard let tableViewController = segue.destinationViewController as? ItemProviderTableViewController else { return }

            let dataSource = ItemProviderTableViewDataSource(itemProvider: itemProvider)
            tableViewController.dataSource = dataSource
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
