import Foundation

public let APIErrorDomain = String(reflecting: APIError.self)

@objc
public enum APIError: Int, ErrorType {
    
    case ResourceDeserialization = 2000
    case ResourceParsing = 2001
    
    case Undefined = 3000
    case ResourceError = 3100
    case ResourceBadRequest = 3101
    case ResourceAuthenticationFailed = 3102
    case ResourceInvalidGrantType = 3103
    case ResourceScopeError = 3104
    case ResourceUnauthorizedClient = 3105
    case ResourceInvalidResponse = 3106
    case BadToken = 3107
    case ElementNotFound = 3108
    case ResourceInvalidData = 3109
    
    case UndefinedValidationError = 4000
    case EmailNotValid = 4001
    case PasswordNotValid = 4002
    
}
