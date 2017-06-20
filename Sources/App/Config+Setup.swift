import LeafProvider
import FluentProvider
import AuthProvider
import JWTProvider

extension Config {
    public func setup() throws {
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        addPreparations()
    }

    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(JWTProvider.Provider.self)
    }

    private func addPreparations() {
        preparations.append(Customer.self)
        preparations.append(Order.self)
        preparations.append(OrderService.self)
        preparations.append(Physician.self)
        preparations.append(Service.self)
        preparations.append(User.self)
        preparations.append(Token.self)
        preparations.append(Pivot<Order, OrderService>.self)
        preparations.append(Pivot<Physician, Service>.self)
    }
}
