//
//  ItemProviderTableViewController.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 23/05/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation
import AVKit
import Contacts
import ContactsUI
import MobileCoreServices

class ItemProviderTableViewController: UITableViewController {
    var dataSource: ItemProviderTableViewDataSource? {
        didSet {
            tableView.dataSource = self.dataSource ?? self
        }
    }
    private(set) var loadedItems: [String : NSSecureCoding] = [:]

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }

        let section = indexPath.section
        let row = indexPath.row

        if section == 0 && row == 1 {
            guard let image = dataSource.loadedPreviewImage else { return }
            print(image)
        } else if section > 0 && row == 3 {
            let index = section - TypeIdentifiersSectionOffset

            let rawTypeIdentifier = dataSource.itemProvider.registeredTypeIdentifiers[index]

            guard let cell = tableView.cellForRow(at: indexPath) else { return }

            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.startAnimating()
            cell.accessoryView = activityIndicator

            showItemForTypeIdentifier(typeIdentifier: rawTypeIdentifier, fromItemProvider: dataSource.itemProvider, completion: { [weak cell] (error) in
                guard let cell = cell else { return }

                cell.accessoryView = nil
            })
        }
    }

    private func loadItemForTypeIdentifier(typeIdentifier: String, fromItemProvider itemProvider: NSItemProvider, completion: ((_ error: Error?, _ item: NSSecureCoding?) -> Void)?) {
        itemProvider.loadItem(forTypeIdentifier: typeIdentifier, options: nil, completionHandler: { [weak self] (item, error) -> Void in
            if let error = error {
                print("Error loading item: \(error)")
                completion?(error, nil)
                return
            }

            guard let item = item else {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                completion?(error, nil)
                return
            }

            OperationQueue.main.addOperation {
                guard let `self` = self else { return }

                self.loadedItems[typeIdentifier] = item
                completion?(nil, item)
            }
        })
    }

    private func showItemForTypeIdentifier(typeIdentifier: String, fromItemProvider itemProvider: NSItemProvider, completion: ((Error?) -> Void)?) {
        func showItem(item: NSSecureCoding) {
            if let image = item as? UIImage {
                displayItemImage(image: image)
                completion?(nil)
            } else if let url = item as? NSURL {
                displayItemURL(url: url, typeIdentifier: typeIdentifier)
                completion?(nil)
            } else if let data = item as? NSData {
                decodeAndDisplayItemData(data: data)
                completion?(nil)
            } else if let text = item as? String {
                displayItemText(text: text)
                completion?(nil)
            } else {
                print("Item unknown")
                print(item)
                completion?(nil)
            }
        }

        if let loadedItem = loadedItems[typeIdentifier as String] {
            showItem(item: loadedItem)
        } else {
            loadItemForTypeIdentifier(typeIdentifier: typeIdentifier, fromItemProvider: itemProvider, completion: { (error, item) in
                if let error = error {
                    completion?(error)
                    return
                }

                guard let item = item else { return }

                showItem(item: item)
            })
        }
    }

    private func displayItemImage(image: UIImage) {
        let vc = DisplayImageViewController(image: image)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func decodeData(data: NSData) -> AnyObject? {
        if #available(iOSApplicationExtension 9.0, *) {
            if let contacts = try? CNContactVCardSerialization.contacts(with: data as Data), contacts.count > 0 {
                return contacts.first
            }
        }

        if let image = UIImage(data: data as Data) {
            return image
        } else if let text = String(data: data as Data, encoding: String.Encoding.utf8) {
            return text as AnyObject
        } else {
            return nil
        }
    }

    private func decodeAndDisplayItemData(data: NSData) {
        if let item = decodeData(data: data) {
            if #available(iOSApplicationExtension 9.0, *) {
                if let contact = item as? CNContact {
                    self.displayContact(contact: contact)
                    return
                }
            }

            if let image = item as? UIImage {
                displayItemImage(image: image)
            } else if let text = item as? String {
                displayItemText(text: text)
            } else {
                displayItemText(text: data.description)
            }
        } else {
            displayItemText(text: data.description)
        }
    }

    private func displayItemURL(url: NSURL, typeIdentifier: String) {
        DispatchQueue.global().async { [weak self] in
            if UTTypeConformsTo(typeIdentifier as CFString, kUTTypeMovie) {
                let player = AVPlayer(url: url as URL)

                if player.error == nil {
                    let playerVC = AVPlayerViewController()
                    playerVC.player = player
                    DispatchQueue.main.async {
                        guard let `self` = self else { return }
                        self.present(playerVC, animated: true, completion: nil)
                    }
                    return
                }
            }

            if let data = NSData(contentsOf: url as URL) {
                guard let `self` = self else { return }

                if let item = self.decodeData(data: data) {
                    if #available(iOSApplicationExtension 9.0, *) {
                        if let contact = item as? CNContact {
                            DispatchQueue.main.async {
                                self.displayContact(contact: contact)
                            }

                            return
                        }
                    }
                    
                    if let image = item as? UIImage {
                        DispatchQueue.main.async {
                            self.displayItemImage(image: image)
                        }
                    } else {
                        DispatchQueue.main.async {
                            func showCopyURLAlert() {
                                let alert = UIAlertController(title: "Can't Open URL", message: "The URL cannot be opened. Copy to clipboard? \(url.absoluteString)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (_) in
                                    UIPasteboard.general.string = url.absoluteString
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }

                            func trySystemOpenURL() {
                                if let extensionContext = self.extensionContext {
                                    extensionContext.open(url as URL, completionHandler: { (complete) in
                                        if !complete {
                                            DispatchQueue.main.async {
                                                showCopyURLAlert()
                                            }
                                        }
                                    })
                                } else {
                                    showCopyURLAlert()
                                }
                            }

                            if url.scheme == "http" || url.scheme == "https" {
                                if #available(iOSApplicationExtension 9.0, *) {
                                    let safariVC = SFSafariViewController(url: url as URL)
                                    self.present(safariVC, animated: true, completion: nil)
                                } else {
                                    trySystemOpenURL()
                                }
                            } else {
                                trySystemOpenURL()
                            }
                        }
                    }
                }
            } else {
                print("Failed to load anything from URL")
            }
        }
    }

    @available(iOS 9.0, *)
    private func displayContact(contact: CNContact) {
        let vc = CNContactViewController(for: contact)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func displayItemText(text: String) {
        let vc = DisplayTextViewController(text: text)
        navigationController?.pushViewController(vc, animated: true)
    }
}

@available(iOSApplicationExtension 9.0, *)
extension ItemProviderTableViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        navigationController?.popViewController(animated: true)
    }
}
