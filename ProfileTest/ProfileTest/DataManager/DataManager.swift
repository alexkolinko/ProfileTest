//
//  DataManager.swift
//  ProfileTest
//
//  Created by kolinko oleksandr on 17.07.2024.
//

import Foundation

class DataManager {
    
    // Method to save profile to UserDefaults
    static func saveProfile(_ profile: ProfileData) {
        do {
            let encoder = JSONEncoder()
            let encodedQuote = try encoder.encode(profile)
            UserDefaults.standard.set(encodedQuote, forKey: "profile")
        } catch {
            print("Error encoding profile: \(error)")
        }
    }
    
    // Method to retrieve profile from UserDefaults
    static func getProfile() -> ProfileData? {
        if let data = UserDefaults.standard.data(forKey: "profile") {
            do {
                let decoder = JSONDecoder()
                let decodedQuote = try decoder.decode(ProfileData.self, from: data)
                return decodedQuote
            } catch {
                print("Error decoding profile: \(error)")
                return nil
            }
        }
        return nil
    }
    
    // Method to delete profile from UserDefaults
    static func deleteProfile() {
        UserDefaults.standard.removeObject(forKey: "profile")
    }
}
