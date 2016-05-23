//
//  ItemProviderTypeIndentifier.swift
//  Share Sheet Debugger
//
//  Created by Joseph Duffy on 23/05/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import Foundation
import MobileCoreServices

enum ItemProviderTypeIndentifier: RawRepresentable {
    case Item
    case Content
    case Image
    case JPEG
    case JPEG2000
    case Unknown(raw: String)

    var rawValue: String {
        switch self {
        case .Item:
            return kUTTypeItem as String
        case .Content:
            return kUTTypeContent as String
        case .Image:
            return kUTTypeImage as String
        case .JPEG:
            return kUTTypeJPEG as String
        case .JPEG2000:
            return kUTTypeJPEG2000 as String
        case .Unknown(let rawValue):
            return rawValue
        }
    }

    init(rawValue: String) {
        switch rawValue {
        case (kUTTypeItem as String as String):
            self = Item
        case (kUTTypeContent as String as String):
            self = Content
        case (kUTTypeImage as String as String):
            self = Image
        case (kUTTypeJPEG as String as String):
            self = JPEG
        case (kUTTypeJPEG2000 as String as String):
            self = JPEG2000
        // TODO: Add more conversions
        default:
            self = Unknown(raw: rawValue)
        }
    }

    func descriptor() -> String {
        switch self {
        case .Item:
            return "Item"
        case .Content:
            return "Content"
        case .Image:
            return "Image"
        case .JPEG:
            return "JPEG"
        case .JPEG2000:
            return "JPEG 2000"
        case .Unknown(raw: _):
            return "Unknown"
        }
    }
}
