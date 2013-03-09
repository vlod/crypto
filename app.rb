
require './crypto'
# Alice sets up a crypto object with her private-public key combo
crypto = Crypto.new File.read("keys/alice.pem")

# and reads the public key of Bob (intended recipient)
bob_public_key = File.read "/tmp/bob.pub"
encrypted_results = crypto.encrypt bob_public_key, "my-secret-plan-for-world-domination"
# xsymm_key: mZ3fKMfyN5MD4D5b8xV8H17fuH+B/6d0fu1/sfMN53I=


# Bob sets up a crypto object with his private-public key combo
crypto = Crypto.new File.read("/tmp/bob.pem")

# # and reads the public key of Alice (apparent sender)
alice_public_key = File.read "/tmp/alice.pub"
decrypted_text = crypto.decrypt alice_public_key, encrypted_results
puts decrypted_text
