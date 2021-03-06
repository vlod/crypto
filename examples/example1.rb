# to run
#   ruby example1.rb
require '../crypto'

# Alice sets up a crypto object with her private-public key combo
crypto = Crypto.new File.read("keys/alice.pem")

# and reads the public key of Bob (intended recipient)
bob_public_key = File.read "keys/bob.pub"
encrypted_results = crypto.encrypt bob_public_key, "my-secret-plan-for-world-domination"



# Bob gets a message apparently from Alice

# Bob sets up a crypto object with his private-public key combo
crypto = Crypto.new File.read("keys/bob.pem")

# and reads the public key of Alice (apparent sender)
alice_public_key = File.read "keys/alice.pub"
decrypted_text = crypto.decrypt alice_public_key, encrypted_results
puts decrypted_text


