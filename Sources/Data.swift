import Foundation

extension Data {
    public var encrypted: Self {
        get async {
            await Task
                .detached(priority: .utility) {
                    Security
                        .encrypt(data: self)
                }
                .value
        }
    }
    
    public var decrypted: Self {
        get async {
            await Task
                .detached(priority: .utility) {
                    Security
                        .decrypt(data: self)
                }
                .value
        }
    }
}
