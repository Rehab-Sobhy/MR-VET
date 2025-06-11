class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: "Discover a Smarter Way to Learn",
    description:
        "Learn anytime, anywhere with personalized lessons just for you!",
    image: "assets/onboarding1.svg",
  ),
  OnboardingItem(
    title: "Your Path, Your Pace",
    description: "Tailored courses to match your goals and learning style.",
    image: "assets/onboarding2.svg",
  ),
];
