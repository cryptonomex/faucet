require 'minitest/autorun'
require 'rubygems'
require 'base58'
require 'digest'

PREFIX = 'BTS'


class Base58

    def initialize(data, prefix=PREFIX)
        @prefix = prefix
        if !str[/\H/]
            @hex = data
        elsif data[0] == '5' or data[0] == '6'
            @hex = base58CheckDecode(data)
        elsif data.start_with? @prefix
            btsBase58CheckDecode(data[@prefix.length..-1])
        else
            raise 'Error loading Base58 object'
        end
    end

    def format(_format)
        case _format.downcase
            when 'wif' then
                base58CheckEncode(0x80, @hex)
            when 'btc' then
                base58CheckEncode(0x00, @hex)
            else
                _format.upcase + self.to_s
        end
    end

    def to_s
        btsBase58CheckEncode(@hex)
    end

end

# def hexlify(msg)
#     msg.split("").collect { |c| c[0].to_s(16) }.join
# end
#
# def unhexlify(msg)
#     msg.scan(/../).collect { |c| c.to_i(16).chr }.join
# end

def hexlify(s)
    a = []
    s.each_byte do |b|
        a << sprintf('%02X', b)
    end
    a.join
end

def unhexlify(s)
    a = s.split
    return a.pack('H*')
end

def base58decode1(base58_str)
    res = Base58.decode(base58_str)
    puts base58_str + " => " + res.to_s(16)
    puts hexlify(res)
    return res.to_s(16)
end

BASE58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".bytes
def base58decode(base58_str)
    base58_text = base58_str.bytes
    n = 0
    leading_zeroes_count = 0
    base58_text.each do |b|
        n = n * 58 + BASE58_ALPHABET.index(b)
        leading_zeroes_count += 1 if n == 0
    end
    res = bytearray()
    while n >= 256:
        div, mod = divmod(n, 256)
        res.insert(0, mod)
        n = div
    else:
        res.insert(0, n)
    print(res)
    print(bytearray(1))
    print(bytearray(1)*leading_zeroes_count + res)
    res = hexlify(bytearray(1)*leading_zeroes_count + res).decode('ascii')
    print(base58_str + " => " + res)
    return res
end

def base58encode(hexstring)
    Base58.encode(hexstring)
end

def ripemd160(s)
    Digest::RMD160.digest unhexlify s
end

def doublesha256(s)
    Digest::SHA256.digest Digest::SHA256.digest unhexlify s
end

def b58encode(v)
    base58encode v
end

def b58decode(v)
    puts v
    res = base58decode v
    puts res
    return res
end

def base58CheckEncode(version, payload)
    s = ('%.2x'%version) + payload
    checksum = doublesha256(s)[0..4]
    result = s + hexlify(checksum).decode('ascii')
    return base58encode(result)
end

def base58CheckDecode(s)
    s = unhexlify(base58decode(s))
    dec = hexlify(s[0..-5])
    checksum = doublesha256(dec)[0..4]
    raise 'error' unless (s[-4..-1] == checksum)
    return dec[2..-1]
end

def btsBase58CheckEncode(s)
    checksum = ripemd160(s)[0..4]
    result = s + hexlify(checksum)
    return base58encode(result)
end

def btsBase58CheckDecode(s)
    s = unhexlify(base58decode(s))
    dec = hexlify(s[0..-5])
    checksum = ripemd160(dec)[0..4]
    raise 'error' unless (s[0..-5] == checksum)
    return dec
end


class Testcases < Minitest::Test
    def test_base58decode
        assert_equal([base58decode('5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ'),
                base58decode('5KYZdUEo39z3FPrtuX2QbbwGnNP5zTd7yyr2SC1j299sBCnWjss'),
                base58decode('5KfazyjBBtR2YeHjNqX5D6MXvqTUd2iZmWusrdDSUqoykTyWQZB')],
            ['800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d507a5b8d',
                '80e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b8555c5bbb26',
                '80f3a375e00cc5147f30bee97bb5d54b31a12eee148a1ac31ac9edc4ecd13bc1f80cc8148e'])
    end

    # def test_base58encode
    #     assert_equal(['5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ',
    #             '5KYZdUEo39z3FPrtuX2QbbwGnNP5zTd7yyr2SC1j299sBCnWjss',
    #             '5KfazyjBBtR2YeHjNqX5D6MXvqTUd2iZmWusrdDSUqoykTyWQZB'],
    #         [base58encode('800c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d507a5b8d'),
    #             base58encode('80e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b8555c5bbb26'),
    #             base58encode('80f3a375e00cc5147f30bee97bb5d54b31a12eee148a1ac31ac9edc4ecd13bc1f80cc8148e')])
    # end
    #
    # def test_btsBase58CheckEncode
    #     assert_equal([btsBase58CheckEncode('02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680'),
    #             btsBase58CheckEncode('021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16'),
    #             btsBase58CheckEncode('02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a'),
    #             btsBase58CheckEncode('03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3'),],
    #         ['6dumtt9swxCqwdPZBGXh9YmHoEjFFnNfwHaTqRbQTghGAY2gRz',
    #             '5725vivYpuFWbeyTifZ5KevnHyqXCi5hwHbNU9cYz1FHbFXCxX',
    #             '6kZKHSuxqAwdCYsMvwTcipoTsNE2jmEUNBQufGYywpniBKXWZK',
    #             '8b82mpnH8YX1E9RHnU2a2YgLTZ8ooevEGP9N15c1yFqhoBvJur'])
    # end
    #
    # def test_btsBase58CheckDecode
    #     assert_equal(['02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680',
    #             '021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16',
    #             '02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a',
    #             '03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3',],
    #         [btsBase58CheckDecode('6dumtt9swxCqwdPZBGXh9YmHoEjFFnNfwHaTqRbQTghGAY2gRz'),
    #             btsBase58CheckDecode('5725vivYpuFWbeyTifZ5KevnHyqXCi5hwHbNU9cYz1FHbFXCxX'),
    #             btsBase58CheckDecode('6kZKHSuxqAwdCYsMvwTcipoTsNE2jmEUNBQufGYywpniBKXWZK'),
    #             btsBase58CheckDecode('8b82mpnH8YX1E9RHnU2a2YgLTZ8ooevEGP9N15c1yFqhoBvJur')])
    # end
    #
    # def test_btsb58
    #     assert_equal(['02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680',
    #             '03457298c4b2c56a8d572c051ca3109dabfe360beb144738180d6c964068ea3e58',
    #             '021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16',
    #             '02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a',
    #             '03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3'],
    #         [btsBase58CheckDecode(btsBase58CheckEncode('02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680')),
    #             btsBase58CheckDecode(btsBase58CheckEncode('03457298c4b2c56a8d572c051ca3109dabfe360beb144738180d6c964068ea3e58')),
    #             btsBase58CheckDecode(btsBase58CheckEncode('021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16')),
    #             btsBase58CheckDecode(btsBase58CheckEncode('02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a')),
    #             btsBase58CheckDecode(btsBase58CheckEncode('03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3'))])
    # end
    #
    # def test_Base58CheckDecode
    #     assert_equal(['02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680',
    #             '021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16',
    #             '02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a',
    #             '03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3',
    #             '02b52e04a0acfe611a4b6963462aca94b6ae02b24e321eda86507661901adb49',
    #             '5b921f7051be5e13e177a0253229903c40493df410ae04f4a450c85568f19131',
    #             '0e1bfc9024d1f55a7855dc690e45b2e089d2d825a4671a3c3c7e4ea4e74ec00e',
    #             '6e5cc4653d46e690c709ed9e0570a2c75a286ad7c1bc69a648aae6855d919d3e',
    #             'b84abd64d66ee1dd614230ebbe9d9c6d66d78d93927c395196666762e9ad69d8',
    #         ], [
    #             base58CheckDecode('KwKM6S22ZZDYw5dxBFhaRyFtcuWjaoxqDDfyCcBYSevnjdfm9Cjo'),
    #             base58CheckDecode('KwHpCk3sLE6VykHymAEyTMRznQ1Uh5ukvFfyDWpGToT7Hf5jzrie'),
    #             base58CheckDecode('KwKTjyQbKe6mfrtsf4TFMtqAf5as5bSp526s341PQEQvq5ZzEo5W'),
    #             base58CheckDecode('KwMJJgtyBxQ9FEvUCzJmvr8tXxB3zNWhkn14mWMCTGSMt5GwGLgz'),
    #             base58CheckDecode('5HqUkGuo62BfcJU5vNhTXKJRXuUi9QSE6jp8C3uBJ2BVHtB8WSd'),
    #             base58CheckDecode('5JWcdkhL3w4RkVPcZMdJsjos22yB5cSkPExerktvKnRNZR5gx1S'),
    #             base58CheckDecode('5HvVz6XMx84aC5KaaBbwYrRLvWE46cH6zVnv4827SBPLorg76oq'),
    #             base58CheckDecode('5Jete5oFNjjk3aUMkKuxgAXsp7ZyhgJbYNiNjHLvq5xzXkiqw7R'),
    #             base58CheckDecode('5KDT58ksNsVKjYShG4Ls5ZtredybSxzmKec8juj7CojZj6LPRF7'),
    #         ])
    # end
    #
    #
    # def test_base58CheckEncodeDecopde
    #     assert_equal(['02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680',
    #             '03457298c4b2c56a8d572c051ca3109dabfe360beb144738180d6c964068ea3e58',
    #             '021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16',
    #             '02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a',
    #             '03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3'],
    #         [base58CheckDecode(base58CheckEncode(0x80, '02e649f63f8e8121345fd7f47d0d185a3ccaa843115cd2e9392dcd9b82263bc680')),
    #             base58CheckDecode(base58CheckEncode(0x80, '03457298c4b2c56a8d572c051ca3109dabfe360beb144738180d6c964068ea3e58')),
    #             base58CheckDecode(base58CheckEncode(0x80, '021c7359cd885c0e319924d97e3980206ad64387aff54908241125b3a88b55ca16')),
    #             base58CheckDecode(base58CheckEncode(0x80, '02f561e0b57a552df3fa1df2d87a906b7a9fc33a83d5d15fa68a644ecb0806b49a')),
    #             base58CheckDecode(base58CheckEncode(0x80, '03e7595c3e6b58f907bee951dc29796f3757307e700ecf3d09307a0cc4a564eba3'))])
    # end
    #
    #
    # def test_Base58
    #     assert_equal([
    #             Base58.new('02b52e04a0acfe611a4b6963462aca94b6ae02b24e321eda86507661901adb49').format('wif'),
    #             Base58.new('5b921f7051be5e13e177a0253229903c40493df410ae04f4a450c85568f19131').format('wif'),
    #             Base58.new('0e1bfc9024d1f55a7855dc690e45b2e089d2d825a4671a3c3c7e4ea4e74ec00e').format('wif'),
    #             Base58.new('6e5cc4653d46e690c709ed9e0570a2c75a286ad7c1bc69a648aae6855d919d3e').format('wif'),
    #             Base58.new('b84abd64d66ee1dd614230ebbe9d9c6d66d78d93927c395196666762e9ad69d8').format('wif'),
    #         ], [
    #             '5HqUkGuo62BfcJU5vNhTXKJRXuUi9QSE6jp8C3uBJ2BVHtB8WSd',
    #             '5JWcdkhL3w4RkVPcZMdJsjos22yB5cSkPExerktvKnRNZR5gx1S',
    #             '5HvVz6XMx84aC5KaaBbwYrRLvWE46cH6zVnv4827SBPLorg76oq',
    #             '5Jete5oFNjjk3aUMkKuxgAXsp7ZyhgJbYNiNjHLvq5xzXkiqw7R',
    #             '5KDT58ksNsVKjYShG4Ls5ZtredybSxzmKec8juj7CojZj6LPRF7',
    #         ])
    # end

end