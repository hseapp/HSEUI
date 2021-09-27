//
//  Color.Base.swift
//  HSEUI
//
//  Created by Matvey Kavtorov on 3/18/21.
//

import UIKit

private extension Bundle {
    
    static var _module: Bundle {
        class T {}
        return Bundle(for: T.self)
    }
    
}

public class Color {

    public class Base {
        public static var mainBackground = UIColor(named: "background", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var label: UIColor = .label

        public static var brandTint = UIColor(named: "brandTint", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var orange: UIColor = .systemOrange

        public static var white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        public static var black = UIColor(named: "black", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var secondary = UIColor(named: "secondary", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var red: UIColor = .systemRed

        public static var separator = UIColor(named: "separator", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var selection = UIColor(named: "selection", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var image = UIColor(named: "image", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var imageBackground = UIColor(named: "grayBackground", in: ._module, compatibleWith: UITraitCollection.current)!
        
        public static var grayBackground = UIColor(named: "grayBackground", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var skeleton = UIColor(named: "skeleton", in: ._module, compatibleWith: UITraitCollection.current)!
        
        public static var placeholder = UIColor(named: "placeholder", in: ._module, compatibleWith: UITraitCollection.current)!
    }

    public class Collection {
        public static var table = UIColor(named: "table", in: ._module, compatibleWith: UITraitCollection.current)!

        public static var header = UIColor(named: "header", in: ._module, compatibleWith: UITraitCollection.current)!
    }

}
