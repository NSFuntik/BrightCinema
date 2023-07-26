//
//  Video.swift
//  BrightCinema
//
//  Created by NSFuntik on 25.07.2023.
//

import Foundation

struct Video: Codable {
    let url: String
    let title: String

}

// MARK: - FilesResponse
struct FilesResponse: Codable {
    let uuid, username, role: String
    let files: [File]
    let createdAt, updatedAt: String
}

// MARK: - File
struct File: Codable {
    let id: Int
    let title: String?
    let uuid, path, size: String
    let userUUID, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, uuid, title, path, size
        case userUUID = "userUuid"
        case createdAt, updatedAt
    }
}
