import Foundation

//Thanks to Said Rehouni for this example ->  https://www.youtube.com/watch?v=UKkH81u-IOM

//Protocol
protocol SignUpRepositoryProtocol {
    func signUp(email: String, pass: String, completion: @escaping (Bool) -> Void )
}
//Main Repository
class SignUpRepository: SignUpRepositoryProtocol {
    
    func signUp(email: String, pass: String, completion: @escaping (Bool) -> Void) {
        //Api call
        completion(true)
    }
}
// Decorator, There may be more than one. With this patron we can extend the functionality of a class without modify the class itself
class SignUpDecoratorRepository: SignUpRepositoryProtocol {
    let inviteCode: String
    let signUpRepository: SignUpRepositoryProtocol
    
    init(inviteCode: String, signUpRepository: SignUpRepositoryProtocol) {
        self.inviteCode = inviteCode
        self.signUpRepository = signUpRepository
    }
    
    func signUp(email: String, pass: String, completion: @escaping (Bool) -> Void) {
        validateInvitation(completion: { [weak self] validated in
            if validated {
                self?.signUpRepository.signUp(email: email, pass: pass, completion: completion)
            } else {
                completion(false)
            }
        })
    }
    
    func validateInvitation(completion: @escaping (Bool) -> Void) {
        // API call
        completion(true)
    }
}

class SignUpUseCase {
    let repository: SignUpRepositoryProtocol
    
    init(repository: SignUpRepositoryProtocol) {
        self.repository = repository
    }
    
    func signUp(email: String, pass: String, completion: @escaping (Bool) -> Void ) {
        repository.signUp(email: email, pass: pass, completion: completion)
    }
}

// Main Composition
func createSignUpUserCase(invitationCode: String?) -> SignUpUseCase {
    var repository: SignUpRepositoryProtocol
    
    if let code = invitationCode {
        repository = SignUpDecoratorRepository(inviteCode: code, signUpRepository: SignUpRepository())
    } else {
        repository = SignUpRepository()
    }
    return SignUpUseCase(repository: repository)
}
