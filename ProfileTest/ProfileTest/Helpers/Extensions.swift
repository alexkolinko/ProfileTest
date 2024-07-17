//
//  Extensions.swift
//  ProfileTest
//
//  Created by kolinko oleksandr on 17.07.2024.
//

import Foundation
import UIKit

extension Date {
    func toString(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
