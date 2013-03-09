require "openssl"
require 'base64'
require 'yaml'
require 'debugger'

# Here are the steps
# * Generates a symmetric random AES-256 key string
# * Encrypt secret-text with this symmetric key
# * Encrypt the symmetric key, with the senders private key (Sender authentication).
# * Encrypt this authenticated key with the recipients public key
# * Returns as base64, the encrypted text and the encrypted symmetric key


class Crypto
  SYMMETRIC_ALG = "AES-256-CBC"

  def initialize(public_private_key_text)
    @pub_prv_key = OpenSSL::PKey::RSA.new public_private_key_text
  end

  def encrypt(recipient_pubkey_text, secret_text)
    recipient_pub_key = OpenSSL::PKey::RSA.new recipient_pubkey_text

    # use a symmetric alg to encrypt, but first generate a random key
    cipher = OpenSSL::Cipher::Cipher.new(SYMMETRIC_ALG)
    cipher.encrypt
    cipher.key = random_symm_key = cipher.random_key

    # apply a sender authentication on the symmetric_key (using the sender private key)
    authenticated_symmetric_key = @pub_prv_key.private_encrypt random_symm_key

    # lets encrypt the the authenticated symm key, with the recipients public key

    # unfort RSA doesn't like to encrypt data that's bigger than its key size. ughh :/
    # so we have to split this all up. *sigh*. might as well base64 it as well
    symm_keys_b64 = []
    authenticated_symmetric_key.bytes.each_slice(117) do |slice|
      symm_keys_b64 << Base64.encode64( recipient_pub_key.public_encrypt(slice.pack('C*')) )
    end

    # and now encrypt the secret_text with the symmetric key, then b64 it
    encrypted_text     = cipher.update(secret_text) + cipher.final
    encrypted_text_b64 = Base64.encode64 encrypted_text

    # serialize all this out
    YAML::dump(keys:symm_keys_b64, body:encrypted_text_b64)
  end

  # reverse of the above
  def decrypt(sender_pubkey_text, data_blob)
    sender_pub_key = OpenSSL::PKey::RSA.new sender_pubkey_text
    data = YAML::load(data_blob)

    # each of the keys are encrypted with the recipients pub_key. decrypt with prv_key
    # we add all these pieces together to form the authenticated symmetrical key
    symm_key = ""
    data[:keys].each do |key|
      symm_key << @pub_prv_key.private_decrypt(Base64.decode64 key)
    end

    # make sure this message really came from the sender
    symmetric_key = sender_pub_key.public_decrypt(symm_key)

    # we now have the original symmetric key, set up the cipher to decrypt
    cipher = OpenSSL::Cipher::Cipher.new(SYMMETRIC_ALG)
    cipher.decrypt
    cipher.key = symmetric_key

    # and return the decrypted text
    plain_text = cipher.update(Base64.decode64 data[:body]) + cipher.final
    plain_text
  end
end

