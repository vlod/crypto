require "openssl"
require 'base64'

# Here are the steps
# 1. Generate a symmetric AES-256 random key string (symm_key)
# 2. Encrypt secret-text with this symmetric key
# 3. Encrypt this symmetric key with the supplied assymetric public key
# 4. Return the encrypted text and the encrypted symmetic key, as base64

class Crypto
  SYMMETRIC_ALG = "AES-256-CBC"

  def encrypt(public_key_text, secret_text)
    # generate a random symmetric key to use to encrypt
    symmetric_key = OpenSSL::Cipher::Cipher.new(SYMMETRIC_ALG).random_key

    # set up the symmetic cipher to encryption
    cipher = OpenSSL::Cipher::Cipher.new(SYMMETRIC_ALG)
    cipher.encrypt
    cipher.key = symmetric_key

    # and encrypt the secret_text
    encrypted_text = cipher.update(secret_text) + cipher.final

    # right, let's encrypt the symmetric_key with the user's public key
    public_key = OpenSSL::PKey::RSA.new public_key_text
    symmetric_key_encrypted = public_key.public_encrypt symmetric_key

    # return results in base64 as we're most likely sending it over http
    symmetric_key_encrypted_b64 = [symmetric_key_encrypted].pack('m')
    encrypted_text_b64          = [encrypted_text].pack('m')

    {key:symmetric_key_encrypted_b64, body:encrypted_text_b64}
  end

  # reverse of the above, but we use the private_key instead
  def decrypt(private_key_text, contents)
    raise "no key supplied"  unless contents[:key]
    raise "no body supplied" unless contents[:body]

    # parameters are in base64, unpack them
    decrypt_key    = contents[:key].unpack('m')[0]
    encrypted_text = contents[:body].unpack('m')[0]

    # the decrypt_key is encrypted with a public key, decrypt with the supplied private key
    private_key = OpenSSL::PKey::RSA.new private_key_text
    symmetric_key = private_key.private_decrypt decrypt_key

    # we have the symmetric key, set up the cipher to decrypt
    cipher = OpenSSL::Cipher::Cipher.new(SYMMETRIC_ALG)
    cipher.decrypt
    cipher.key = symmetric_key

    # and return the decrypted text
    plain_text = cipher.update(encrypted_text) + cipher.final
    plain_text
  end
end
