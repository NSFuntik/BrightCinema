//
//  User.swift
//  BrightCinema
//
//  Created by NSFuntik on 10.07.2023.
//

import Foundation

// MARK: - AccessData
struct AccessData: Codable {
    let accessToken: String
}

enum AccessType: String {
    case REGISTER = "auth/register"
    case LOGIN = "auth/login"
}

struct AccessParameters: Codable {
    let username, fingerprint, password: String
//    let rememberMe: Bool

    enum CodingKeys: String, CodingKey {
        case username, fingerprint, password
//        case rememberMe = "remember_me"
    }
}
