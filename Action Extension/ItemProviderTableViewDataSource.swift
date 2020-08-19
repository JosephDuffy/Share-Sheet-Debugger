//
//  ItemProviderTableViewDataSource.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 22/05/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import MobileCoreServices

let MetaDataSection = 0
let TypeIdentifiersSectionOffset = 1

class ItemProviderTableViewDataSource: NSObject, UITableViewDataSource {
    let itemProvider: NSItemProvider
    private(set) var loadedPreviewImage: NSSecureCoding?

    init(itemProvider: NSItemProvider) {
        self.itemProvider = itemProvider
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + itemProvider.registeredTypeIdentifiers.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case MetaDataSection:
            return 2
        default:
            // Specific type identifier
            return 4
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case MetaDataSection:
            switch row {
            case 0:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Type Identifiers Count"
                cell.detailTextLabel?.text = "\(itemProvider.registeredTypeIdentifiers.count)"
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Preview Image"
                cell.selectionStyle = .none

                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.startAnimating()
                cell.accessoryView = activityIndicator
                itemProvider.loadPreviewImage(options: [:], completionHandler: { [weak cell, weak self] (image, error) in
                    guard let `self` = self else { return }
                    guard let cell = cell else { return }

                    OperationQueue.main.addOperation {
                        cell.accessoryView = nil

                        if let error = error {
                            cell.detailTextLabel?.text = "Error"
                            cell.accessoryType = .none
                            cell.selectionStyle = .none
                            print("Error loading preview image: \(error)")
                            return
                        }

                        if let image = image {
                            self.loadedPreviewImage = image
                            cell.detailTextLabel?.text = "Available"
                            cell.accessoryType = .disclosureIndicator
                            cell.selectionStyle = .default
                        } else {
                            cell.detailTextLabel?.text = "Not Available"
                            cell.accessoryType = .none
                            cell.selectionStyle = .none
                        }
                    }
                })
                return cell
            default:
                fatalError("Cannot retrieve cell for index path: \(indexPath)")
            }
        default:
            let index = section - TypeIdentifiersSectionOffset
            let rawTypeIdentifier = itemProvider.registeredTypeIdentifiers[index]
            
            let typeIdentifier = ItemProviderTypeIndentifier(rawValue: rawTypeIdentifier)

            switch row {
            case 0:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Raw Type"
                cell.detailTextLabel?.text = typeIdentifier.rawValue
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Friendly Type"
                cell.detailTextLabel?.text = typeIdentifier.descriptor()
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Object Type"
                cell.selectionStyle = .none

                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.startAnimating()
                cell.accessoryView = activityIndicator
                itemProvider.loadItem(forTypeIdentifier: rawTypeIdentifier, options: nil, completionHandler: { [weak cell] (item, error) -> Void in
                    guard let cell = cell else { return }
                    OperationQueue.main.addOperation {
                        cell.accessoryView = nil

                        if let error = error {
                            print("Error: \(error)")
                            cell.detailTextLabel?.text = "Error"
                            return
                        }

                        guard let item = item else {
                            cell.detailTextLabel?.text = "Error"
                            return
                        }

                        if item is NSURL {
                            cell.detailTextLabel?.text = "NSURL"
                        } else if item is String {
                            cell.detailTextLabel?.text = "String"
                        } else if item is NSData {
                            cell.detailTextLabel?.text = "NSData"
                        } else {
                            cell.detailTextLabel?.text = "Unknown"
                        }
                    }
                    })
                return cell
            case 3:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "View Data"
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = UIButton().tintColor
                return cell
            default:
                fatalError("Cannot retrieve cell for index path: \(indexPath)")
            }
        }
    }
}
