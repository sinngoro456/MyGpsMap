//
//  iconForMapItem.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2025/02/25.
//

import MapKit

class IconForMapItem {
    // MKMapItemのカテゴリに応じたアイコンを返す関数
    static func iconForMapItem(_ mapItem: MKMapItem) -> String {
        // iOS 13以降で利用可能なpointOfInterestCategoryを使用
        if #available(iOS 13.0, *), let category = mapItem.pointOfInterestCategory {
            switch category {
            case .airport:
                return "airplane"
            case .amusementPark:
                return "ticket"
            case .aquarium:
                return "fish"
            case .atm:
                return "dollarsign.circle"
            case .bakery:
                return "birthday.cake"
            case .bank:
                return "banknote"
            case .beach:
                return "beach.umbrella"
            case .brewery:
                return "mug"
            case .cafe:
                return "cup.and.saucer"
            case .campground:
                return "tent"
            case .carRental:
                return "car"
            case .evCharger:
                return "bolt.car"
            case .fireStation:
                return "flame"
            case .fitnessCenter:
                return "dumbbell"
            case .foodMarket:
                return "cart"
            case .gasStation:
                return "fuelpump"
            case .hospital:
                return "cross"
            case .hotel:
                return "bed.double"
            case .laundry:
                return "washer"
            case .library:
                return "book"
            case .marina:
                return "sailboat"
            case .movieTheater:
                return "film"
            case .museum:
                return "building.columns"
            case .nationalPark:
                return "leaf"
            case .nightlife:
                return "moon"
            case .park:
                return "tree"
            case .parking:
                return "parkingsign"
            case .pharmacy:
                return "pills"
            case .police:
                return "shield"
            case .postOffice:
                return "envelope"
            case .publicTransport:
                return "bus"
            case .restaurant:
                return "fork.knife"
            case .restroom:
                return "toilet"
            case .school:
                return "graduationcap"
            case .stadium:
                return "sportscourt"
            case .store:
                return "bag"
            case .theater:
                return "ticket"
            case .university:
                return "graduationcap"
            case .winery:
                return "wineglass"
            case .zoo:
                return "ant"
            default:
                break
            }
        }

        // pointOfInterestCategoryが利用できない場合、名前やタイトルから推測
        if let name = mapItem.name?.lowercased() {
            if name.contains("airport") {
                return "airplane"
            } else if name.contains("restaurant") || name.contains("cafe") {
                return "fork.knife"
            } else if name.contains("hotel") {
                return "bed.double"
            } else if name.contains("gas station") {
                return "fuelpump"
            } else if name.contains("hospital") {
                return "cross"
            } else if name.contains("school") || name.contains("university") {
                return "graduationcap"
            } else if name.contains("park") {
                return "tree"
            } else if name.contains("store") || name.contains("shop") {
                return "bag"
            }
        }

        // デフォルトのピンアイコン
        return "mappin"
    }
}