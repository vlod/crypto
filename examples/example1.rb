require '../crypto'

my_secret_text = "my secret plan for world domination"
user_public_key = File.read "keys/user.pub"
puts "Encrypting text:[#{my_secret_text}]"
encrypted_results = Crypto.new.encrypt user_public_key, my_secret_text
puts "Encrypted: #{encrypted_results}\n--\n"


user_private_key = File.read "keys/user.pem"
results = Crypto.new.decrypt user_private_key, encrypted_results
puts "Decrypted text:[#{results}]"