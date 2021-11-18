public enum Tag: UInt8, CaseIterable, Comparable, Identifiable {
    public var id: UInt8 {
        rawValue
    }
    
    case
    home,
    office,
    work,
    family,
    important,
    top,
    partner,
    critical,
    fun,
    school,
    utilities,
    other,
    security,
    children,
    pets,
    food,
    snacks,
    drinks,
    animals,
    travel,
    books,
    miscellaneous,
    spy,
    codes,
    passwords,
    numbers,
    keys,
    cook,
    tools,
    biscuits,
    hidden,
    friends,
    kids,
    eco,
    documents,
    official,
    credentials,
    apps,
    programs,
    software,
    computer,
    mobile,
    phone,
    keycode,
    contact,
    bank,
    account,
    card,
    date,
    verification,
    token,
    job,
    human,
    resources,
    person,
    people,
    parents,
    address,
    referral,
    website,
    delivery,
    services,
    feminism,
    lgbt,
    vegetarian,
    vegan,
    iphone,
    ipad,
    watch,
    mac
    
    public var name: String {
        "\(self)"
    }
    
    public static func filtering(search: String) -> [Self] {
        { components in
            components.isEmpty
            ? allCases
            : allCases
                .filter { tag in
                    components
                        .contains {
                            tag
                                .name
                                .localizedCaseInsensitiveContains($0)
                        }
                }
        } (search
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter {
                !$0.isEmpty
            })
            .sorted()
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}
