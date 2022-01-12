import HSEUI

private func Tag() -> Int { return Nonce() }

enum ViewTag {
    static let `default` = 0

    static let overflowTag = Tag()
}
