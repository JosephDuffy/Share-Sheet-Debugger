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

    var itemProvider: NSItemProvider? {
        didSet {
            setupForItemProvider()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupForItemProvider() {
        guard let itemProvider = self.itemProvider else {
            return
        }

        let typeIdentifiersCount = itemProvider.registeredTypeIdentifiers.count
        if typeIdentifiersCount > 1 {
            textLabel?.text = "\(typeIdentifiersCount) Types"
            accessoryType = .DisclosureIndicator
        } else if let rawTypeIdentifier = itemProvider.registeredTypeIdentifiers.first as? String where typeIdentifiersCount == 1 {
            let typeIdentifier = ItemProviderTypeIndentifier(rawValue: rawTypeIdentifier)
            textLabel?.text = typeIdentifier.descriptor()
            accessoryType = .DisclosureIndicator

            itemProvider.loadItemForTypeIdentifier(rawTypeIdentifier, options: nil, completionHandler: { [weak self] (item, error) -> Void in
                guard let `self` = self else { return }

                if let error = error {
                    print("Error: \(error)")
                    return
                }

                guard let item = item else {
                    return
                }

                NSOperationQueue.mainQueue().addOperationWithBlock {
                    if item is NSURL {
                        self.detailTextLabel?.text = "NSURL"
                    } else if item is String {
                        self.detailTextLabel?.text = "String"
                    } else if item is NSData {
                        self.detailTextLabel?.text = "NSData"
                    } else {
                        self.detailTextLabel?.text = "Unknown"
                    }
                }
            })
        } else {
            textLabel?.text = "Error loading identifiers"
            accessoryType = .DisclosureIndicator
        }
    }

}
