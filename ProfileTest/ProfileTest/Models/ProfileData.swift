//
//  ProfileData.swift
//  ProfileTest
//
//  Created by kolinko oleksandr on 17.07.2024.
//

import Foundation

struct ProfileData: Hashable, Codable {
    var imageData: Data?
    var fullName: String
    var gender: Gender
    var birthday: Date
    var phone: String
    var email: String
    var userName: String
}
