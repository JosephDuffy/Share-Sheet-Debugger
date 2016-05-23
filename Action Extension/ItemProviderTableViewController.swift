//
//  ItemProviderTableViewController.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 23/05/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit

class ItemProviderTableViewController: UITableViewController {
    var dataSource: ItemProviderTableViewDataSource? {
        didSet {
            tableView.dataSource = self.dataSource ?? self
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let dataSource = dataSource else { return }

        let section = indexPath.section
        let row = indexPath.row

        if section == 0 && row == 1 {
            guard let image = dataSource.loadedPreviewImage else { return }
            print(image)
        }
    }
}
