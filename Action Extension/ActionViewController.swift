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

    private(set) var itemProviders: [NSItemProvider] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(ItemProviderTableViewCell.self, forCellReuseIdentifier: ItemProviderTableViewCell.resuseIdentifier)

        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }

        for inputItem in inputItems {
            guard let itemProviders = inputItem.attachments as? [NSItemProvider] else {
                continue
            }

            print(inputItem)

            for (index, itemProvider) in itemProviders.enumerate() {
                print(itemProvider)
                
                tableView.beginUpdates()
                self.itemProviders.append(itemProvider)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: self.itemProviders.count - 1)], withRowAnimation: .Automatic)
                tableView.endUpdates()
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemProviders.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemProviders[section].registeredTypeIdentifiers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let itemProvider = itemProviders[indexPath.section]
        let typeIdentifier = itemProvider.registeredTypeIdentifiers[indexPath.row] as! String

        let cell = tableView.dequeueReusableCellWithIdentifier(ItemProviderTableViewCell.resuseIdentifier, forIndexPath: indexPath) as! ItemProviderTableViewCell

        cell.setItemProvider(itemProvider, typeIdentifier: typeIdentifier)

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(ShowItemProviderDetailSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShowItemProviderDetailSegue {
            guard let cell = sender as? ItemProviderTableViewCell else {
                return
            }

            guard let itemProviderDetailsViewController = segue.destinationViewController as? ItemProviderDetailsViewController else {
                return
            }

            itemProviderDetailsViewController.setItemProvider(cell.itemProvider!, typeIdentifier: cell.typeIdentifier!)
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
