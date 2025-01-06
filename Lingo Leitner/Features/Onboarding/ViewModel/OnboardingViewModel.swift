import UIKit

final class OnboardingViewModel {
    private static func configureImage(systemName: String) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .light)
        return UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(Theme.accent, renderingMode: .alwaysOriginal) ?? UIImage()
    }
    
    let slides: [OnboardingSlide] = [
        OnboardingSlide(
            image: configureImage(systemName: "brain.head.profile"),
            title: "Kelime Öğrenmenin En Etkili Yolu",
            description: "Leitner sistemi, bilimsel olarak kanıtlanmış bir öğrenme metodudur. Bu sistem, beynin nasıl öğrendiğini ve bilgiyi nasıl kalıcı hale getirdiğini temel alır."
        ),
        OnboardingSlide(
            image: configureImage(systemName: "rectangle.stack.fill.badge.plus"),
            title: "Akıllı Tekrar Sistemi",
            description: "Her kelime kartı, öğrenme durumunuza göre farklı kutularda saklanır. İyi bildiğiniz kelimeler daha seyrek, zorlandığınız kelimeler daha sık karşınıza çıkar."
        ),
        OnboardingSlide(
            image: configureImage(systemName: "person.fill.checkmark"),
            title: "Kişiselleştirilmiş Öğrenme",
            description: "Sistem sizin öğrenme hızınıza ve performansınıza göre kendini otomatik olarak ayarlar. Böylece her kelimeyi en uygun zamanda tekrar edersiniz."
        ),
        OnboardingSlide(
            image: configureImage(systemName: "chart.line.uptrend.xyaxis.circle.fill"),
            title: "Başarınızı Takip Edin",
            description: "Günlük, haftalık ve aylık ilerleme raporlarıyla motivasyonunuzu yüksek tutun. Hedeflerinize ne kadar yaklaştığınızı görün."
        )
    ]
} 
