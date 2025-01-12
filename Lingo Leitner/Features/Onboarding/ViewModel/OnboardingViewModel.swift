import UIKit

final class OnboardingViewModel {
    private static func configureImage(systemName: String) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .light)
        return UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(Theme.accent, renderingMode: .alwaysOriginal) ?? UIImage()
    }
    
    let slides: [OnboardingSlide] = [
        OnboardingSlide(
//            image: configureImage(systemName: "brain.head.profile"),
            image: UIImage(named: "onboarding1")!,
            title: "onboarding_title_1".localized,
            description: "onboarding_desc_1".localized
        ),
        OnboardingSlide(
//            image: configureImage(systemName: "rectangle.stack.fill.badge.plus"),
            image: UIImage(named: "onboarding2")!,
            title: "onboarding_title_2".localized,
            description: "onboarding_desc_2".localized
        ),
        OnboardingSlide(
//            image: configureImage(systemName: "person.fill.checkmark"),
            image: UIImage(named: "onboarding3")!,
            title: "onboarding_title_3".localized,
            description: "onboarding_desc_3".localized
        ),
        OnboardingSlide(
//            image: configureImage(systemName: "chart.line.uptrend.xyaxis.circle.fill"),
            image: UIImage(named: "onboarding4")!,
            title: "onboarding_title_4".localized,
            description: "onboarding_desc_4".localized
        )
    ]
} 
