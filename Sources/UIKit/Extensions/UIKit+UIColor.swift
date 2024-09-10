import UIKit

extension UIColor {
    
    static var random: UIColor {
        let value = Int.random(in: 0x000000 ... 0xFFFFFF)
        return .hex(value)
    }
    
    static func hex(_ value: Int, alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    var hexString: String {
      guard let components = cgColor.components else { return "000000" }
      let r = components[0]
      let g = components[1]
      let b = components[2]
      return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

//    convenience init(hex: Int, alpha: CGFloat = 1.0) {
//        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
//        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
//        let b = CGFloat(hex & 0xFF) / 255.0
//        self.init(red: r, green: g, blue: b, alpha: alpha)
//    }
//    convenience init(hex: Int, alpha: CGFloat = 1.0) {
//        self.init(
//            red: (hex >> 16) & 0xFF,
//            green: (hex >> 8) & 0xFF,
//            blue: hex & 0xFF,
//            alpha: alpha
//        )
//    }

