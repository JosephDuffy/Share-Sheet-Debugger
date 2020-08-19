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
    case URL
    case PlainText
    case Image
    case JPEG
    case JPEG2000
    case PNG
    case MPEG4
    case ContactCard
    case Unknown(raw: String)

    var rawValue: String {
        switch self {
        case .Item:
            return kUTTypeItem as String
        case .Content:
            return kUTTypeContent as String
        case .URL:
            return kUTTypeURL as String
        case .PlainText:
            return kUTTypePlainText as String
        case .Image:
            return kUTTypeImage as String
        case .JPEG:
            return kUTTypeJPEG as String
        case .JPEG2000:
            return kUTTypeJPEG2000 as String
        case .PNG:
            return kUTTypePNG as String
        case .MPEG4:
            return kUTTypeMPEG4 as String
        case .ContactCard:
            return kUTTypeVCard as String
        case .Unknown(let rawValue):
            return rawValue
        }
    }

    init(rawValue: String) {
        switch rawValue {
        case (kUTTypeItem as String as String):
            self = ItemProviderTypeIndentifier.Item
        case (kUTTypeContent as String as String):
            self = ItemProviderTypeIndentifier.Content
        case (kUTTypeURL as String as String):
            self = ItemProviderTypeIndentifier.URL
        case (kUTTypePlainText as String as String):
            self = ItemProviderTypeIndentifier.PlainText
        case (kUTTypeImage as String as String):
            self = ItemProviderTypeIndentifier.Image
        case (kUTTypeJPEG as String as String):
            self = ItemProviderTypeIndentifier.JPEG
        case (kUTTypeJPEG2000 as String as String):
            self = ItemProviderTypeIndentifier.JPEG2000
        case (kUTTypePNG as String as String):
            self = ItemProviderTypeIndentifier.PNG
        case (kUTTypeMPEG4 as String as String):
            self = ItemProviderTypeIndentifier.MPEG4
        case (kUTTypeVCard as String as String):
            self = ItemProviderTypeIndentifier.ContactCard
        // TODO: Add more conversions
        default:
            self = ItemProviderTypeIndentifier.Unknown(raw: rawValue)
        }
    }

    func descriptor() -> String {
        switch self {
        case .Item:
            return "Item"
        case .Content:
            return "Content"
        case .URL:
            return "URL"
        case .PlainText:
            return "Plain Text"
        case .Image:
            return "Image"
        case .JPEG:
            return "Image (JPEG)"
        case .JPEG2000:
            return "Image (JPEG 2000)"
        case .PNG:
            return "Image (PNG)"
        case .MPEG4:
            return "Video (MPEG4)"
        case .ContactCard:
            return "Contact Card"
        case .Unknown(raw: _):
            return "Unknown"
        }
    }
}
