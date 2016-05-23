//
//  ItemProviderDetailsViewController.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 26/02/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit

class ItemProviderDetailsViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    private(set) var itemProvider: NSItemProvider?
    private(set) var typeIdentifier: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setItemProvider(itemProvider: NSItemProvider, typeIdentifier: String?) {
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

        title = typeIdentifier

        itemProvider.loadItemForTypeIdentifier(typeIdentifier as String, options: nil, completionHandler: { (item, error) -> Void in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let item = item else {
                return
            }

            NSOperationQueue.mainQueue().addOperationWithBlock {
                if let item = item as? NSURL {
                    self.textView.text = item.absoluteString
                } else if let item = item as? String {
                    self.textView.text = item
                } else if let item = item as? NSData {
                    if let dataAsString = String(data: item, encoding: NSUTF8StringEncoding) {
                        self.textView.text = dataAsString
                    } else {
                        self.textView.text = item.description
                    }
                } else {
                    self.textView.text = "Unknown"
                }
            }
        })
    }

}
