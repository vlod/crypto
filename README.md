crypto
======

Simple way to pass public-key encrypted (and authenticated) messages.

Problem
------------------

Alice wants to share top secret plans to take over the world to Bob, making sure that he know it came from her and not from their arch enemy [Chuck](http://en.wikipedia.org/wiki/Alice_and_Bob). 


Behind The Curtain
------------------

Here are the steps it performs:

* Generates a symmetric random AES-256 key string
* Encrypt secret-text with this symmetric key
* Encrypt the symmetric key, with the senders private key (Sender authentication).
* Encrypt this authenticated key with the recipients public key
* Returns as base64, the encrypted text and the encrypted symmetric key


Dependencies
------------

Crypto needs openssl. Install it as:

    gem install openssl


Usage
-----

Alice wants to send a message to Bob, making sure the the message is authenticated, so that Bob knows it came from Alice.

First we need to generate a public-private key pair for our 2 users

    $ openssl genrsa -out /tmp/alice.pem 1024
    $ openssl genrsa -out /tmp/bob.pem 1024

Extract the public_key:

    $ openssl rsa -in /tmp/alice.pem -pubout > /tmp/alice.pub
    $ openssl rsa -in /tmp/bob.pem -pubout > /tmp/bob.pub


Then it's super simple to encrypt with the user's public key:

	require './crypto'
    # Alice sets up a crypto object with her private-public key combo
    crypto = Crypto.new File.read("/tmp/alice.pem")

	# reads the public key of Bob (intended recipient)
    bob_public_key = File.read "/tmp/bob.pub"
    # and encrypts her super secret plans
    encrypted_results = crypto.encrypt bob_public_key, "my-secret-plan-for-world-domination"

Likewise to decrypt:
    # Bob gets a message apparently from Alice

    # Bob sets up a crypto object with his private-public key combo
    crypto = Crypto.new File.read("/tmp/bob.pem")

    # and reads the public key of Alice (apparent sender) 
    # so we can make sure it really came from her
    alice_public_key = File.read "/tmp/alice.pub"

    # it definitely came from alice, ok decrypt the message
    decrypted_text = crypto.decrypt alice_public_key, encrypted_results
    puts decrypted_text

    -> "my-secret-plan-for-world-domination"


Examples
--------

For a working example, take a look at [examples](https://github.com/vlod/crypto/tree/master/examples).



Authors
-------

* **Vlod Kalicun** ([Twitter](https://twitter.com/vlod) / [GitHub](https://github.com/vlod))




License
-------

Licensed under the MIT License

If you're so inclined, shoot me an email at: vlod [@] vlod.com on how you're using it.
I'm always curious if you're doing anything cool! :)

