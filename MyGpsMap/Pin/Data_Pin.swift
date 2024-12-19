import Foundation
import UIKit
import CoreLocation

class Data_Pin: Codable {
    var id: Int?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var description: String?
    var color: UIColor?
    var images: [UIImage]
    var date: Date?  // 日付を格納するプロパティを追加
    var category: String?
    var tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id, coordinate, title, description, color, images, date, category, tags
    }

    // CLLocationCoordinate2D用のCodable拡張
    struct CoordinateWrapper: Codable {
        var latitude: Double
        var longitude: Double
        
        init(coordinate: CLLocationCoordinate2D) {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
        
        func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        // CLLocationCoordinate2DからCoordinateWrapperへの変換
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            latitude = try container.decode(Double.self, forKey: .latitude)
            longitude = try container.decode(Double.self, forKey: .longitude)
        }
        
        // CoordinateWrapperからCLLocationCoordinate2Dへの変換
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(latitude, forKey: .latitude)
            try container.encode(longitude, forKey: .longitude)
        }
        
        private enum CodingKeys: String, CodingKey {
            case latitude, longitude
        }
    }

    // UIColorをCodableにするためのカスタムエンコーディング
    private enum ColorCodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        
        // CoordinateWrapperを使用して緯度と経度をデコード
        let coordinateWrapper = try container.decode(CoordinateWrapper.self, forKey: .coordinate)
        coordinate = CLLocationCoordinate2D(latitude: coordinateWrapper.latitude, longitude: coordinateWrapper.longitude)

        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        // UIColorをデコード
        if let colorContainer = try? container.nestedContainer(keyedBy: ColorCodingKeys.self, forKey: .color) {
            let red = try colorContainer.decode(CGFloat.self, forKey: .red)
            let green = try colorContainer.decode(CGFloat.self, forKey: .green)
            let blue = try colorContainer.decode(CGFloat.self, forKey: .blue)
            let alpha = try colorContainer.decode(CGFloat.self, forKey: .alpha)
            color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            color = nil
        }

        // UIImageのBase64エンコーディングをデコードしてUIImageに戻す
        images = [] // ここでは一時的に空の配列で初期化します。
        
        if let imageStrings = try? container.decode([String].self, forKey: .images) {
            images = imageStrings.compactMap { imageString in
                if let data = Data(base64Encoded: imageString),
                   let image = UIImage(data: data) {
                    return image
                }
                return nil
            }
        }

        date = try container.decodeIfPresent(Date.self, forKey: .date)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)

        // CoordinateWrapperに変換してエンコード
        let coordinateWrapper = CoordinateWrapper(coordinate: coordinate)
        try container.encode(coordinateWrapper, forKey: .coordinate)

        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)

        // UIColorをエンコード
        if let color = color {
            let components = color.cgColor.components ?? [0.0, 0.0, 0.0, 1.0]
            var colorContainer = container.nestedContainer(keyedBy: ColorCodingKeys.self, forKey: .color)
            try colorContainer.encode(components[0], forKey: .red)   // Red
            try colorContainer.encode(components[1], forKey: .green) // Green
            try colorContainer.encode(components[2], forKey: .blue)  // Blue
            try colorContainer.encode(components[3], forKey: .alpha) // Alpha
        }

        // UIImageをBase64エンコーディングして保存
        let imageStrings = images.map { image in
            image.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? ""
        }
        
        try container.encode(imageStrings, forKey: .images)
        
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(tags, forKey: .tags)
    }

    init(id: Int? = nil,
         coordinate: CLLocationCoordinate2D,
         title: String? = "新しいピン",
         description: String? = nil,
         color: UIColor? = .orange,
         images: [UIImage] = [],
         date: Date? = nil,
         category: String? = nil,
         tags: [String]? = nil) {
        
        self.id = id ?? 0
        self.coordinate = coordinate // CoordinateWrapperで初期化しない（元の形式）
        self.title = title
        self.description = description
        self.color = color ?? .orange
        
        // 画像をBase64エンコードして保存（元の形式）
        self.images = images
        
        self.date = date  // 初期化時に日付を設定
        self.category = category
        self.tags = tags
    }
    
    // JSONへの変換メソッド
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // 日付フォーマット設定
        do {
            return try encoder.encode(self)
        } catch {
            print("JSONエンコードエラー:", error)
            return nil
        }
    }
}
