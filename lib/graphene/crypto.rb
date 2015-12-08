require 'minitest/autorun'
require_relative './base58'

class Address

    def initialize(address=nil, pubkey=nil, prefix='BTS')
        if pubkey
            @pubkey = Base58(pubkey, prefix)
            @address = nil
        elsif address
            @pubkey = nil
            @address = Base58(address, prefix)
        else
            raise Exception('Address has to be initialized by either the pubkey or the address.')
        end
    end

    # def derivesha256address
    #     pkbin         = unhexlify(repr(@pubkey))
    #     addressbin    = ripemd160(hexlify(hashlib.sha256(pkbin).digest()))
    #     return Base58(hexlify(addressbin).decode('ascii'))
    #  end

end

class Testcases < Minitest::Test

    def test_B85hexgetb58
        # assert_equal(['BTS2CAbTi1ZcgMJ5otBFZSGZJKJenwGa9NvkLxsrS49Kr8JsiSGc',
        #         'BTShL45FEyUVSVV1LXABQnh4joS9FsUaffRtsdarB5uZjPsrwMZF',
        #         'BTS7DQR5GsfVaw4wJXzA3TogDhuQ8tUR2Ggj8pwyNCJXheHehL4Q',
        #         'BTSqc4QMAJHAkna65i8U4b7nkbWk4VYSWpZebW7JBbD7MN8FB5sc',
        #         'BTS2QAVTJnJQvLUY4RDrtxzX9jS39gEq8gbqYMWjgMxvsvZTJxDSu'
        #     ], [format(Base58('02b52e04a0acfe611a4b6963462aca94b6ae02b24e321eda86507661901adb49'), 'BTS'),
        #         format(Base58('5b921f7051be5e13e177a0253229903c40493df410ae04f4a450c85568f19131'), 'BTS'),
        #         format(Base58('0e1bfc9024d1f55a7855dc690e45b2e089d2d825a4671a3c3c7e4ea4e74ec00e'), 'BTS'),
        #         format(Base58('6e5cc4653d46e690c709ed9e0570a2c75a286ad7c1bc69a648aae6855d919d3e'), 'BTS'),
        #         format(Base58('b84abd64d66ee1dd614230ebbe9d9c6d66d78d93927c395196666762e9ad69d8'), 'BTS')])
    end

    def test_address
        # assert_equal([
        #         format(Address("BTSFN9r6VYzBK8EKtMewfNbfiGCr56pHDBFi"), "BTS"),
        #         format(Address("BTSdXrrTXimLb6TEt3nHnePwFmBT6Cck112"), "BTS"),
        #         format(Address("BTSJQUAt4gz4civ8gSs5srTK4r82F7HvpChk"), "BTS"),
        #         format(Address("BTSFPXXHXXGbyTBwdKoJaAPXRnhFNtTRS4EL"), "BTS"),
        #         format(Address("BTS3qXyZnjJneeAddgNDYNYXbF7ARZrRv5dr"), "BTS"),
        #     ], [
        #         "BTSFN9r6VYzBK8EKtMewfNbfiGCr56pHDBFi",
        #         "BTSdXrrTXimLb6TEt3nHnePwFmBT6Cck112",
        #         "BTSJQUAt4gz4civ8gSs5srTK4r82F7HvpChk",
        #         "BTSFPXXHXXGbyTBwdKoJaAPXRnhFNtTRS4EL",
        #         "BTS3qXyZnjJneeAddgNDYNYXbF7ARZrRv5dr",
        #     ])
    end

end
