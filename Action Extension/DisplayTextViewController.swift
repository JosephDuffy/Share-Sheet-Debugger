//
//  DisplayTextViewController.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 23/05/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit

class DisplayTextViewController: UIViewController {
    let text: String

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = self.text
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    init(text: String) {
        self.text = text

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupForText()
    }

    private func setupForText() {
        view.addSubview(textView)

        view.addConstraints([
            NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            ])
    }
}
