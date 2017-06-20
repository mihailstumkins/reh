import Vapor
import AuthProvider
import JWT
import JWTProvider

final class Routes: RouteCollection {
    let signer: Signer?
    let view: ViewRenderer
    let hash: HashProtocol

    init(signer: Signer?, hash: HashProtocol, view: ViewRenderer) {
        self.signer = signer
        self.hash = hash
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {

        builder.get { req in
            return try self.view.make("welcome")
        }

        builder.post("login") { req in
            guard let email = req.json?["email"]?.string,
                  let password = req.json?["password"]?.string else {
                return try Response(status: .badRequest, json: JSON(node: ["error": "Missing email or password"]))
            }

            let hashedPassword = try self.hash.make(password.makeBytes()).makeString()
            let credentials = Password(username: email, password: hashedPassword)
            let user = try User.authenticate(credentials)
            req.auth.authenticate(user)

            guard let userId = user.id?.int else {
                return try Response(status: .badRequest, json: JSON(node: ["error": "Could not find your account. Please try authenticating again."]))
            }

            return try JSON(node: [
                "access_token": try self.createJwtToken(String(userId)),
                "user": user
            ])
        }

        builder.post("register") { req in
            guard let name = req.json?["name"]?.string,
                  let surname = req.json?["surname"]?.string,
                  let email = req.json?["email"]?.string,
                  let phone = req.json?["phone"]?.string,
                  let password = req.json?["password"]?.string else {
                return try Response(status: .badRequest, json: JSON(node: ["error": "Missing required parameters"]))
            }

            guard try User.makeQuery().filter("email", email).first() == nil else {
                return try Response(status: .badRequest, json: JSON(node: ["error": "A user with that email already exists."]))
            }


            let hashedPassword = try self.hash.make(password.makeBytes()).makeString()
            let user = try User.register(name: name, surname: surname, email: email, phone: phone, password: hashedPassword)
            

            let credentials = Password(username: user.email, password: hashedPassword)
            try req.auth.authenticate(User.authenticate(credentials))
            try user.save()

            guard let userId = user.id?.int else {
                return try Response(status: .badRequest, json: JSON(node: [
                    "error": "Could not generate authentication token. Your account was created so please reauthenticate and try again."
                    ]))
            }

            return try JSON(node: [
                "access_token": try self.createJwtToken(String(userId)),
                "user": user
            ])
        }

        let tokenMiddleware = PayloadAuthenticationMiddleware(self.signer!,[], User.self)
        let authed = builder.grouped(tokenMiddleware)


        authed.get("logout") { req in
            try req.auth.unauthenticate()
            return try JSON(node: ["success": true])
        }

        authed.get("me") { req in
            let user = try req.user()
            return try JSON(node: [
                "user": user
            ])
        }
        /*
        builder.get("orders") { req in
            return try Order.all().makeJSON()
        }

        builder.get("test/orders") { req in
            guard let customer = try Customer.all().first else {
                throw Abort.badRequest
            }

            let order = Order(customerId: customer.id!, applicant: "someone", address: "somewhere")
            try order.save()
            return try order.makeJSON()
        }
        */

        /// GET /customer/...
//        builder.resource("customers", CustomerController())
    }
}
extension Routes {
    func  createJwtToken(_ userId: String)  throws -> String {

        guard  let sig = self.signer else { throw Abort.unauthorized }

        let timeToLive = 5 * 60.0 // 5 minutes
        let claims:[Claim] = [
            ExpirationTimeClaim(date: Date().addingTimeInterval(timeToLive)),
            SubjectClaim(string: userId)
        ]

        let payload = JSON(claims)
        let jwt = try JWT(payload: payload, signer: sig)

        return try jwt.createToken()
    }
}
