crypto
======

Simple way to pass public-key encrypted messages


Behind The Curtain
------------------

Here are the steps it performs:

* Generates a symmetric random AES-256 key string
* Encrypt secret-text with this symmetric key
* Encrypt this symmetric key with the supplied assymetric public key
* Returns as base64, the encrypted text and the encrypted symmetric key


Dependencies
------------

Crypto needs openssl. Install it as:

    gem install openssl


Usage
-----

First we need to generate a public-private key pair:

    $ openssl genrsa -out /tmp/user.pem 1024

Extract the public_key:

    $ openssl rsa -in /tmp/user.pem -pubout > /tmp/user.pub
    
    
Then it's super simple to encrypt with the user's public key:

	require './crypto'
	# read the public key of your intended recipient
    user_public_key = File.read "/tmp/user.pub"
    encrypted_results = Crypto.new.encrypt user_public_key, "my-secret-plan-for-world-domination" 
    
Likewise to decrypt:

    # recipient reads their private key
    user_private_key = File.read "/tmp/user.pem"
    decrypted_text = Crypto.new.decrypt user_private_key, encrypted_results
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

