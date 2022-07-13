import Foundation

private class NonceManager {

    static let main = NonceManager()

    var nonce = 0

}

public func Nonce() -> Int {
    NonceManager.main.nonce += 1
    return NonceManager.main.nonce
}
