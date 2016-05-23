//
//  ItemProviderTableViewController.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 23/05/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import SafariServices

class ItemProviderTableViewController: UITableViewController {
    var dataSource: ItemProviderTableViewDataSource? {
        didSet {
            tableView.dataSource = self.dataSource ?? self
        }
    }
    private(set) var loadedItems: [String : NSSecureCoding] = [:]

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let dataSource = dataSource else { return }

        let section = indexPath.section
        let row = indexPath.row

        if section == 0 && row == 1 {
            guard let image = dataSource.loadedPreviewImage else { return }
            print(image)
        } else if section > 0 && row == 3 {
            let index = section - TypeIdentifiersSectionOffset

            guard let rawTypeIdentifier = dataSource.itemProvider.registeredTypeIdentifiers[index] as? String else {
                return
            }

            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }

            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityIndicator.startAnimating()
            cell.accessoryView = activityIndicator

            showItemForTypeIdentifier(rawTypeIdentifier, fromItemProvider: dataSource.itemProvider, completion: { [weak cell] (error) in
                guard let cell = cell else { return }

                cell.accessoryView = nil
            })
        }
    }

    private func loadItemForTypeIdentifier(typeIdentifier: String, fromItemProvider itemProvider: NSItemProvider, completion: ((error: ErrorType?, item: NSSecureCoding?) -> Void)?) {
        itemProvider.loadItemForTypeIdentifier(typeIdentifier, options: nil, completionHandler: { [weak self] (item, error) -> Void in
            if let error = error {
                print("Error loading item: \(error)")
                completion?(error: error, item: nil)
                return
            }

            guard let item = item else {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                completion?(error: error, item: nil)
                return
            }

            NSOperationQueue.mainQueue().addOperationWithBlock {
                guard let `self` = self else { return }

                self.loadedItems[typeIdentifier] = item
                completion?(error: nil, item: item)
            }
        })
    }

    private func showItemForTypeIdentifier(typeIdentifier: String, fromItemProvider itemProvider: NSItemProvider, completion: ((ErrorType?) -> Void)?) {
        func showItem(item: NSSecureCoding) {
            if let image = item as? UIImage {
                displayItemImage(image)
                completion?(nil)
            } else if let url = item as? NSURL {
                displayItemURL(url)
                completion?(nil)
            } else if let data = item as? NSData {
                decodeAndDisplayItemData(data)
                completion?(nil)
            } else if let text = item as? String {
                displayItemText(text)
            } else {
                print("Item unknown")
                print(item)
                completion?(nil)
            }
        }

        if let loadedItem = loadedItems[typeIdentifier as String] {
            showItem(loadedItem)
        } else {
            loadItemForTypeIdentifier(typeIdentifier, fromItemProvider: itemProvider, completion: { (error, item) in
                if let error = error {
                    completion?(error)
                    return
                }

                guard let item = item else { return }

                showItem(item)
            })
        }
    }

    private func displayItemImage(image: UIImage) {
        let vc = DisplayImageViewController(image: image)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func decodeAndDisplayItemData(data: NSData) {
        if let image = UIImage(data: data) {
            displayItemImage(image)
        } else if let text = String(data: data, encoding: NSUTF8StringEncoding) {
            displayItemText(text)
        } else {
            displayItemText(data.description)
        }
    }

    private func displayItemURL(url: NSURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            if let data = NSData(contentsOfURL: url) {
                if let image = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue()) {
                        guard let `self` = self else { return }

                        self.displayItemImage(image)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        guard let `self` = self else { return }

                        if url.scheme == "http" || url.scheme == "https" {
                            if #available(iOSApplicationExtension 9.0, *) {
                                let safariVC = SFSafariViewController(URL: url)
                                self.presentViewController(safariVC, animated: true, completion: nil)
                            } else {
                                // Fallback on earlier versions
                            }
                        } else {
                            func showCopyURLAlert() {
                                let alert = UIAlertController(title: "Can't open", message: "The URL cannot be opened. Copy to clipboard? \(url.absoluteString)", preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                                alert.addAction(UIAlertAction(title: "Copy", style: .Default, handler: { (_) in
                                    UIPasteboard.generalPasteboard().string = url.absoluteString
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }

                            if let extensionContext = self.extensionContext {
                                extensionContext.openURL(url, completionHandler: { (complete) in
                                    if !complete {
                                        showCopyURLAlert()
                                    }
                                })
                            } else {
                                showCopyURLAlert()
                            }
                        }
                    }
                }
            } else {
                print("Failed to load anything from URL")
            }
        }

        if url.scheme == "http" || url.scheme == "https" {
            if #available(iOSApplicationExtension 9.0, *) {
                let safariVC = SFSafariViewController(URL: url)
                self.presentViewController(safariVC, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        } else {
            print("Opening URL: \(url)")
            self.extensionContext?.openURL(url, completionHandler: { (complete) in
                print("Opened URL: \(complete)")
            })
        }
    }

    private func displayItemText(text: String) {
        let vc = DisplayTextViewController(text: text)
        navigationController?.pushViewController(vc, animated: true)
    }
}
