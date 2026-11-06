import DesignSystem
import Testing

struct ProfileAvatarTests {
    @Test(arguments: [
        ("Nicolai Dam", "ND"),
        ("Nicolai Christian Dam", "ND"),
        ("  Nicolai   Dam  ", "ND"),
        ("Nicolai", "N"),
        ("Åse Øster", "ÅØ"),
        ("Éva Öberg", "ÉÖ")
    ])
    func usesFirstAndLastNameGraphemes(name: String, expected: String) {
        #expect(ProfileAvatarView.initials(for: name) == expected)
    }

    @Test
    func missingNamesUseThePersonIcon() {
        #expect(ProfileAvatarView.initials(for: nil) == nil)
        #expect(ProfileAvatarView.initials(for: " \n\t ") == nil)
    }
}
