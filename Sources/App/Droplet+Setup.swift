@_exported import Vapor

extension Droplet {
    public func setup() throws {

        let routes = Routes(signer: signer, hash: hash, view: view)
        try collection(routes)
    }
}
