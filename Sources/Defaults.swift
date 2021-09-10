import Foundation

public enum Defaults: String {
    case
    _rated,
    _created,
    _onboarded,
    _authenticate,
    _tools,
    _spell,
    _correction

    public static var rated: Bool {
        get { self[._rated] as? Bool ?? false }
        set { self[._rated] = newValue }
    }
    
    public static var created: Date? {
        get { self[._created] as? Date }
        set { self[._created] = newValue }
    }
    
    public static var onboarded: Bool {
        get { self[._onboarded] as? Bool ?? false }
        set { self[._onboarded] = newValue }
    }
    
    public static var authenticate: Bool {
        get { self[._authenticate] as? Bool ?? false }
        set { self[._authenticate] = newValue }
    }
    
    public static var tools: Bool {
        get { self[._tools] as? Bool ?? true }
        set { self[._tools] = newValue }
    }
    
    public static var spell: Bool {
        get { self[._spell] as? Bool ?? true }
        set { self[._spell] = newValue }
    }
    
    public static var correction: Bool {
        get { self[._correction] as? Bool ?? false }
        set { self[._correction] = newValue }
    }
    
    private static subscript(_ key: Self) -> Any? {
        get { UserDefaults.standard.object(forKey: key.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: key.rawValue) }
    }
}
