import ExceptionCatcher

public func suppressExceptions<T>(in block: @escaping () -> (T?)) -> T? {
    var result: T?
    try? Exceptions.intercept {
        result = block()
    }
    return result
}
