import UIKit

public enum FontWeight {
    
    case medium
    case regular
    case semibold
    case bold
    
    public init(_ weight: UIFont.Weight) {
        switch weight {
        case .black, .bold, .heavy:
            self = .bold
            
        case .medium:
            self = .medium
            
        case .semibold:
            self = .semibold
            
        default:
            self = .regular
        }
    }
    
}

public protocol FontCollection {
    
    func main(weight: FontWeight) -> UIFont
    
    var header: UIFont { get }
    
    var defaultSize: CGFloat { get }
    
}

public extension FontCollection {
    
    var main: UIFont {
        return self.main(weight: .regular)
    }
    
}

public class DefaultFontCollection: FontCollection {
    
    public func main(weight: FontWeight) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "SFProText-Regular", size: defaultSize) ?? .systemFont(ofSize: defaultSize, weight: .regular)
            
        case .medium:
            return UIFont(name: "SFProText-Medium", size: defaultSize) ?? .systemFont(ofSize: defaultSize, weight: .medium)
            
        case .semibold:
            return UIFont(name: "SFProText-Semibold", size: defaultSize) ?? .systemFont(ofSize: defaultSize, weight: .semibold)
            
        case .bold:
            return UIFont(name: "SFProText-Bold", size: defaultSize) ?? .systemFont(ofSize: defaultSize, weight: .bold)
        }
    }
    
    public var header: UIFont {
        return UIFont(name: "FuturaNewMedium-Reg", size: defaultSize)!
    }
    
    public var defaultSize: CGFloat {
        return 17
    }
    
}

public var Font: FontCollection {
    return HSEUISettings.main.fontCollection
}


