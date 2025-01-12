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
            return "Giriş yapılamadı"
        case .signUpFailed:
            return "Üyelik oluşturulamadı"
        case .userNotFound:
            return "Kullanıcı bulunamadı"
        case .invalidEmail:
            return "Geçersiz e-posta adresi"
        case .weakPassword:
            return "Şifre çok zayıf"
        case .emailAlreadyInUse:
            return "Bu e-posta adresi zaten kullanımda"
        case .notImplemented:
            return "Bu özellik henüz kullanılamıyor"
        case .unknown:
            return "Bilinmeyen bir hata oluştu"
        case .emptyFields:
            return "Lütfen tüm alanları doldurun"
        case .permissionDenied:
            return "Google hesabınıza erişim izni reddedildi. Lütfen izinleri kontrol edin ve tekrar deneyin."
        case .networkError:
            return "Ağ bağlantısı hatası"
        case .invalidCredentials:
            return "Geçersiz kimlik bilgileri"
        case .invalidInput:
            return "Geçersiz giriş. Lütfen tüm alanları doğru doldurun."
        }
    }
} 
