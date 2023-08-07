//
//  Sidebar.swift
//  BrightWidgets
//
//  Created by NSFuntik on 25.05.2023.
//

import SwiftUI
import StoreKit

enum Tab: Int {
    case signIn = 4000,  highlights = 4001, main = 4002, search = 4003, bookmarks = 4004, videos = 4005, arcinema = 4006
}
struct MenuItemBadge: Identifiable {
    var id: Tab
    var icon: String
    var text: String
}

var userActions: [MenuItemBadge] = [
    MenuItemBadge(id: Tab.signIn, icon: "signin", text: "Sign In"),
    MenuItemBadge(id: Tab.highlights, icon: "TV", text: "Weekly highlights"),
    MenuItemBadge(id: .main, icon: "logo", text: "Movies"),
    MenuItemBadge(id: .search, icon: "search", text: "Search"),
    MenuItemBadge(id: .bookmarks, icon: "bookmark", text: "Bookmarks"),
    MenuItemBadge(id: .videos, icon: "videos", text: "My Library"),
    MenuItemBadge(id: .arcinema, icon: "ARCinema", text: "AR Cinema")

]


