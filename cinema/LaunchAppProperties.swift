//
//  LaunchAppProperties.swift
//  OliScheme
//
//  Created by NSFuntik on 16.05.2023.
//

import Foundation

struct LaunchAppProperties {
  static func fill(AppsFlyerId: String, Keitaro: String, KeitaroId: String) {
        LaunchAppProperties.AppsFlyerId = AppsFlyerId
        LaunchAppProperties.Keitaro = Keitaro
        LaunchAppProperties.KeitaroId = KeitaroId

    }
    static var AppsFlyerId: String = ""
    static let Tds: String = "https://vymhsy.com/"
    static var Keitaro: String = ""
    static var KeitaroId: String = ""
    static let AppsFlyerDevKey: String = "v38voSV5xRBKmwGHgxepLG"
}

enum Preference: String {
    case PrivateContent
    case CommonContent
}

public struct SettingsScenesPrivate {
    public struct global {
        public static var privacyB = false
        public static var url = ""
    }
}

struct AdditionalParamsAppsflyer {
    var c: String?
    var af_sub1: String?
    var af_sub2: String?
    var af_sub3: String?
    var af_sub4: String?
    var af_sub5: String?
    var ompixel: String?
    var clickid: String?
    var fbclid: String?
    var af_ad_id: String?
    var af_ad: String?
    var af_adset: String?
    var af_adset_id: String?
    var af_site_id: String?
    var af_siteid: String?
}

var urlForLocation: String = ""
