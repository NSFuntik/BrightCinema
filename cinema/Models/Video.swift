//
//  Video.swift
//  BrightCinema
//
//  Created by NSFuntik on 25.07.2023.
//

import Foundation

struct Video: Codable {
    let url: String
    let name: String

}
//"uuid": "bc14dbde-2257-4a5f-8b65-56b0f4a37e23",
//   "username": "001327.3b66061d958047c782e51dc2898d25a5.1253",
//   "role": "USER",
//   "videos": [
//       {
//           "id": 1,
//           "uuid": "cd64978f-7eaa-4008-9da3-cc945abe0c00",
//           "name": "Vision Pro",
//           "url": "https://www.apple.com/105/media/us/apple-vision-pro/2023/7e268c13-eb22-493d-a860-f0637bacb569/films/product/vision-pro-product-tpl-us-2023_16x9.m3u8",
//           "userUuid": "bc14dbde-2257-4a5f-8b65-56b0f4a37e23",
//           "createdAt": "2023-08-01T10:32:56.666Z",
//           "updatedAt": "2023-08-01T10:32:56.666Z"
//       }
//   ],
//   "createdAt": "2023-07-25T10:21:07.689Z",
//   "updatedAt": "2023-07-25T10:21:07.689Z"
//}
// MARK: - FilesResponse
struct FilesResponse: Codable {
    let uuid, username, role: String
    let videos: [File]
    let createdAt, updatedAt: String
}

// MARK: - File
struct File: Codable {
    let id: Int
    let name: String?
    let uuid, url: String
    let userUUID, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, url
        case userUUID = "userUuid"
        case createdAt, updatedAt
    }
}
//{
//    "id": 1,
//    "uuid": "cd64978f-7eaa-4008-9da3-cc945abe0c00",
//    "name": "Vision Pro",
//    "url": "https://www.apple.com/105/media/us/apple-vision-pro/2023/7e268c13-eb22-493d-a860-f0637bacb569/films/product/vision-pro-product-tpl-us-2023_16x9.m3u8",
//    "userUuid": "bc14dbde-2257-4a5f-8b65-56b0f4a37e23",
//    "createdAt": "2023-08-01T10:32:56.666Z",
//    "updatedAt": "2023-08-01T10:32:56.666Z"
