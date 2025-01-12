import Foundation

enum AuthError: LocalizedError {
    case signInFailed
    case signUpFailed
    case userNotFound
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case notImplemented
    case unknown
    case emptyFields
    case permissionDenied
    case networkError
    case invalidCredentials
    case invalidInput
    
    var message: String {
        switch self {
        case .signInFailed:
            return "auth_error_sign_in_failed".localized
        case .signUpFailed:
            return "auth_error_sign_up_failed".localized
        case .userNotFound:
            return "auth_error_user_not_found".localized
        case .invalidEmail:
            return "auth_error_invalid_email".localized
        case .weakPassword:
            return "auth_error_weak_password".localized
        case .emailAlreadyInUse:
            return "auth_error_email_in_use".localized
        case .notImplemented:
            return "auth_error_not_implemented".localized
        case .unknown:
            return "auth_error_unknown".localized
        case .emptyFields:
            return "auth_error_empty_fields".localized
        case .permissionDenied:
            return "auth_error_permission_denied".localized
        case .networkError:
            return "auth_error_network".localized
        case .invalidCredentials:
            return "auth_error_invalid_credentials".localized
        case .invalidInput:
            return "auth_error_invalid_input".localized
        }
    }
} 
