public enum Tag: UInt8, CaseIterable, Comparable {
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
    pet,
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
    tools
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        "\(lhs)".localizedCompare("\(rhs)") == .orderedAscending
    }
}
