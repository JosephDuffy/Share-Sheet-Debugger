//
//  ItemProviderTableViewCell.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 26/02/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import MobileCoreServices

class ItemProviderTableViewCell: UITableViewCell {
    static let resuseIdentifier = "ItemProviderTableViewCell"

    private(set) var itemProvider: NSItemProvider?
    private(set) var typeIdentifier: String?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)

        accessoryType = .DisclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setItemProvider(itemProvider: NSItemProvider, typeIdentifier: String) {
        self.itemProvider = itemProvider
        self.typeIdentifier = typeIdentifier
        setupForItemProvider()
    }

    private func setupForItemProvider() {
        guard let itemProvider = self.itemProvider else {
            return
        }
        guard let typeIdentifier = self.typeIdentifier else {
            return
        }

        textLabel?.text = typeIdentifier

        itemProvider.loadItemForTypeIdentifier(typeIdentifier as String, options: nil, completionHandler: { [weak self] (item, error) -> Void in
            guard let `self` = self else { return }

            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let item = item else {
                return
            }

            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let item = item as? NSURL {
                    self.textLabel?.text = "NSURL"
                    self.detailTextLabel?.text = item.absoluteString
                } else if let item = item as? String {
                    self.textLabel?.text = "String"
                    self.detailTextLabel?.text = item
                } else if item is NSData {
                    self.detailTextLabel?.text = "NSData"
                } else {
                    self.detailTextLabel?.text = "Unknown"
                }
            }
        })
    }

}
