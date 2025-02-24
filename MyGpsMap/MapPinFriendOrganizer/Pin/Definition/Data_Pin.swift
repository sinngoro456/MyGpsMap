import Foundation
import UIKit
import CoreLocation
import AWSCore
import AWSS3
import Alamofire

class Data_Pin: Codable, Equatable {
    static func == (lhs: Data_Pin, rhs: Data_Pin) -> Bool {
        return lhs.user_id == rhs.user_id &&
        lhs.pin_id == rhs.pin_id &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.color == rhs.color &&
        areImagesEqual(lhs.images, rhs.images) &&
        lhs.date == rhs.date &&
        lhs.category == rhs.category &&
        lhs.tags == rhs.tags &&
        lhs.visibility == rhs.visibility
    }
    
    var user_id: String?
    var pin_id: String?
    var latitude: Double
    var longitude: Double
    var title: String?
    var description: String?
    var color: UIColor?
    var images: [UIImage]
    var date: Date?
    var category: String?
    var tags: [String]?
    var visibility: String?

    enum CodingKeys: String, CodingKey {
        case user_id, pin_id, latitude, longitude, title, description, color, images, date, category, tags, visibility
    }

    // UIColorをCodableにするためのカスタムエンコーディング
    private enum ColorCodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user_id = try container.decodeIfPresent(String.self, forKey: .user_id)
        pin_id = try container.decodeIfPresent(String.self, forKey: .pin_id)
        
        // 緯度と経度を個別にデコード
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)

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
        images = []
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
        visibility = try container.decodeIfPresent(String.self, forKey: .visibility)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(user_id, forKey: .user_id)
        try container.encodeIfPresent(pin_id, forKey: .pin_id)

        // 緯度と経度を個別にエンコード
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)

        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)

        // UIColorをエンコード
        if let color = color {
            var colorContainer = container.nestedContainer(keyedBy: ColorCodingKeys.self, forKey: .color)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            try colorContainer.encode(r, forKey: .red)
            try colorContainer.encode(g, forKey: .green)
            try colorContainer.encode(b, forKey: .blue)
            try colorContainer.encode(a, forKey: .alpha)
        }

        // UIImageをBase64エンコーディングして保存
        let imageStrings = images.map { image in
            image.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? ""
        }
        try container.encode(imageStrings, forKey: .images)
        
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(visibility, forKey: .visibility)
    }

    init(user_id: String? = UserSessionManager.shared.user_id,
         pin_id: String = "",
         coordinate: CLLocationCoordinate2D,
         title: String? = "新しいピン",
         description: String? = nil,
         color: UIColor? = .orange,
         images: [UIImage] = [],
         date: Date? = nil,
         category: String? = nil,
         tags: [String]? = nil,
         visibility: String? = "private"
    ) {
        self.user_id = user_id
        self.pin_id = pin_id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.title = title
        self.description = description
        self.color = color ?? .orange
        self.images = images
        self.date = date
        self.category = category
        self.tags = tags
        self.visibility = visibility
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

    // CLLocationCoordinate2Dを取得するためのプロパティ
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Data_Pin {
    // DBに対応した辞書型へのエンコードメソッド
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["user_id"] = user_id
        dict["pin_id"] = pin_id
        dict["latitude"] = Int(latitude * 1e13)
        dict["longitude"] = Int(longitude * 1e13)
        print(latitude)
        dict["title"] = title
        dict["description"] = description
        
        if let color = color {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            dict["color"] = ["red": r, "green": g, "blue": b, "alpha": a]
        }
        
        // imagesの有無に応じて要素数を設定
        dict["images"] = images.count // imagesの要素数を整数で設定
        
        if let date = date {
            let formatter = ISO8601DateFormatter()
            dict["date"] = formatter.string(from: date)
        }
        
        dict["category"] = category
        dict["tags"] = tags
        dict["visibility"] = visibility
        
        return dict
    }
    
    // 辞書型からのデコードメソッド（イニシャライザ）
    convenience init?(fromDictionary dict: [String: Any]) {
        guard let latitudeInt = dict["latitude"] as? Int,
              let longitudeInt = dict["longitude"] as? Int else {
            return nil
        }

        let latitude = Double(latitudeInt) / 1e13
        let longitude = Double(longitudeInt) / 1e13
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.init(coordinate: coordinate)
        user_id = dict["user_id"] as? String
        pin_id = (dict["pin_id"] as! String)
        title = dict["title"] as? String
        description = dict["description"] as? String
        if let colorDict = dict["color"] as? [String: CGFloat] {
            color = UIColor(red: colorDict["red"] ?? 0,
                            green: colorDict["green"] ?? 0,
                            blue: colorDict["blue"] ?? 0,
                            alpha: colorDict["alpha"] ?? 1)
        }
        // imagesは空の配列で初期化
        images = []
        if let dateString = dict["date"] as? String {
            let formatter = ISO8601DateFormatter()
            date = formatter.date(from: dateString)
        }
        category = dict["category"] as? String
        tags = dict["tags"] as? [String]
        visibility = dict["visibility"] as? String
    }
    
    // 画像の内容を比較するメソッド
    private static func areImagesEqual(_ images1: [UIImage], _ images2: [UIImage]) -> Bool {
        guard images1.count == images2.count else { return false }
        
        for (index, image1) in images1.enumerated() {
            let image2 = images2[index]
            if image1.size != image2.size {
                return false
            }
        }
        return true
    }
}
extension Data_Pin: Identifiable {
    var id: String {
        // pin_id が nil の場合は 0、または -1 等にしておく
        pin_id ?? ""
    }
}
