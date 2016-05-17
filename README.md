[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# SASLKit

SASLKit provides an implementation of the _Simple Authentication and Security Layer_ as specified in [RFC 4422](https://tools.ietf.org/rfc/rfc4422.txt).

Supported mechanisms are:

 * PLAIN

## Installation

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SASLKit into you Xcode project using Carthage, specify it in your Cartfile:

```
github "Internetslum/SASLKit" ~> 1.0
```

## Usage

### Mechanism

All supported mechanisms are registered in base class `SASLMechanism`. To create a mechanism object, get the class for the mechanism by it's name from the registered mechanisms.

```objc
Class mechanismClass = [[SASLMechanism registeredMechanisms] objectForKey:@"PLAIN"];
if (mechanismClass) {
    SASLMechanism *mechanism = [[mechanismClass alloc] init];
}
```

To start an authentication exchange, invoke the method `beginAuthenticationExchangeWithHostname:responseHandler:`:

```objc
[mechanism beginAuthenticationExchangeWithHostname:@"localhost"
                                   responseHandler:^(NSData *initialResponse, BOOL abort) {
                                       if (abort == NO) {
                                           // Send the initial response to the server …
                                       }
}];
```

Further challenge-response-exchange can be done via `handleChallenge:responseHandler:`:

```objc
[mechanism handleChallenge:someData
           responseHandler:^(NSData *initialResponse, BOOL abort) {
               if (abort == NO) {
                   // Send the response to the server …
               }
}];
```

If the authentication succeeds, the exchange can be completed via `succeedWithData:` providing optional outcome message, or via `failedWithError:` if the authentication did fail.

### Delegate

If the mechanism needs credentials to complete the authentication, it asks the delegate by invoking `SASLMechanismNeedsCredentials:`. The delegate can then provide the required credentials (e.g., username and password).

```objc
- (void)SASLMechanismNeedsCredentials:(SASLMechanism *)mechanism
{
    if ([mechanism isKindOfClass:[SASLMechanismPLAIN class]]) {
        SASLMechanismPLAIN *plainMechanism = (SASLMechanismPLAIN *)mechanism;
        [plainMechanism authenticateWithUsername:@"romeo"
                                        password:@"123"
                                      completion:^(BOOL success, NSError *error) {
                                          // Called after the authentication exchange
                                      }];
    }
}
```

## Contributing

SASLKit uses [git-flow](http://nvie.com/posts/a-successful-git-branching-model/) as branching model. New feature should always be started from the `develop` branch.

To contribute:

1. Fork it!
2. Create your feature branch (prefixed with feature): `git checkout -b feature/my-new-feature develop`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request :D

Before submitting a pull request, format the sources according to the `.clang-format` file in the repository. You can do so by invoking the script `./clang-formt.sh` also in the root of the repository.

## License

See LICENSE.md in the root of this repository.
