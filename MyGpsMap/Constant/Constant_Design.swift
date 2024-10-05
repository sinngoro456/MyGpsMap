import UIKit

class Constants_Design {
    // 色の定数
    static let profileButtonBackgroundColor = UIColor.white
    static let profileButtonTintColor = UIColor.systemBlue
    static let destinationTextFieldBackGroundColor = UIColor.white

    // サイズの定数
    static let buttonCornerRadius: CGFloat = 8.0
    static let buttonWidth: CGFloat = 40.0
    static let buttonHeight: CGFloat = 40.0

    // 位置の定数 +:下or右, -:上or左
    static let compassButtonTop: CGFloat? = 10
    static let compassButtonBottom: CGFloat? = nil
    static let compassButtonLeading: CGFloat? = nil
    static let compassButtonTrailing: CGFloat? = -10

    static let profileButtonTop: CGFloat? = nil
    static let profileButtonBottom: CGFloat? = 10
    static let profileButtonLeading: CGFloat? = nil
    static let profileButtonTrailing: CGFloat? = -10.0

    static let userTrackingButtonTop: CGFloat? = -40
    static let userTrackingButtonBottom: CGFloat? = nil
    static let userTrackingButtonLeading: CGFloat? = nil
    static let userTrackingButtonTrailing: CGFloat? = -10

    static let spotifyButtonTop: CGFloat? = -40
    static let spotifyButtonBottom: CGFloat? = nil
    static let spotifyButtonLeading: CGFloat? = 60
    static let spotifyButtonTrailing: CGFloat? = nil

    static let radikoButtonTop: CGFloat? = -40
    static let radikoButtonBottom: CGFloat? = nil
    static let radikoButtonLeading: CGFloat? = 10
    static let radikoButtonTrailing: CGFloat? = nil

    // スタイル
    static let destinationTextFieldBorderStyle: UITextField.BorderStyle = .roundedRect

    // 文字列の定数
    static let destinationTextFieldPlaceholder = "目的地を入力"
    static let spotifyButtonImageName = "play.circle"
    static let profileButtonImageName = "person.circle"
    static let radikoButtonImageName = "radio"
    static let userTrackingButtonNone = "location"
    static let userTrackingButtonFollow = "location.fill"
    static let userTrackingButtonFollowWithHeading = "location.slash"

    // その他の数値定数
    static let destinationTextFieldBottom: CGFloat = -10
    static let destinationTextFieldWidth: CGFloat = 250
    static let destinationTextFieldHeight: CGFloat = 40
}
