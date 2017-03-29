#encoding: utf-8
require 'openssl'
require "base64"
module Ddt
  module WeixinCrypt

    class WeixinMessageError < ::StandardError
    end

    module SHA1
      # 计算公众平台的消息签名接口
      def self.get(token, timestamp, nonce, encrypt)
        # 用SHA1算法生成安全签名
        # @param token:  票据
        # @param timestamp: 时间戳
        # @param encrypt: 密文
        # @param nonce: 随机字符串
        # @return: 安全签名
        string_array = [token, timestamp, nonce, encrypt]
        Digest::SHA1.hexdigest(string_array.map(&:to_s).sort.join)
      end
    end

    module XMLParse
      # 提供提取消息格式中的密文及生成回复消息格式的接口
      # xml消息模板
      @@aes_text_response_template = "<xml>
        <Encrypt><![CDATA[%{msg_encrypt}]]></Encrypt>
        <MsgSignature><![CDATA[%{msg_signaturet}]]></MsgSignature>
        <TimeStamp>%{timestamp}</TimeStamp>
        <Nonce><![CDATA[%{nonce}]]></Nonce>
        </xml>".gsub(/\s+/, "")

      def self.extract(xmltext)
        # 提取出xml数据包中的加密消息
        # @param xmltext: 待提取的xml字符串
        # @return: 提取出的加密消息字符串
        hash = Hash.from_xml(xmltext).to_options[:xml].to_options
        [hash[:Encrypt], hash[:ToUserName]]
      end

      def self.generate(encrypt, signature, timestamp, nonce)
        # 生成xml消息
        # @param encrypt: 加密后的消息密文
        # @param signature: 安全签名
        # @param timestamp: 时间戳
        # @param nonce: 随机字符串
        # @return: 生成的xml字符串
        resp_dict = {
                      msg_encrypt: encrypt,
                      msg_signaturet: signature,
                      timestamp: timestamp,
                      nonce: nonce,
                    }
        @@aes_text_response_template % resp_dict
      end
    end

    module PKCS7Encoder
      # 提供基于PKCS7算法的加解密接口
      @@block_size = 32
      def self.encode(text)
        # 对需要加密的明文进行填充补位
        # @param text: 需要进行填充补位操作的明文
        # @return: 补齐明文字符串
        text_length = text.bytesize
        # 计算需要填充的位数
        amount_to_pad = @@block_size - (text_length % @@block_size)
        amount_to_pad = @@block_size if amount_to_pad == 0
        # 获得补位所用的字符
        pad = amount_to_pad.chr
        text + pad * amount_to_pad
      end

      def self.decode(decrypted)
        # 删除解密后明文的补位字符
        # @param decrypted: 解密后的明文
        # @return: 删除补位字符后的明文
        pad = decrypted[-1].ord
        pad = 0 if pad < 1 or pad > 32
        decrypted[0...-pad]
      end
    end

    module Prpcrypt
      # 提供接收和推送给公众平台消息的加解密接口
      # 加解密模式为AES 256 CBC模式

      def self.encrypt(key, text, appid)
        # 对明文进行加密
        # @param key: key
        # @param text: 需要加密的明文
        # @return: 加密得到的字符串

        # 16位随机字符串添加到明文开头
        text = self.get_random_str() + [text.bytesize].pack('N').bytes.to_a.pack('c*').force_encoding("utf-8") + text + appid
        # 使用自定义的填充方式对明文进行补位填充
        text = PKCS7Encoder.encode(text)
        # 加密
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt
        cipher.padding = 0
        cipher.key = key
        cipher.iv = key[0..16]
        cipher_text = cipher.update(text) + cipher.final
        # 使用BASE64对加密后的字符串进行编码
        Base64.encode64(cipher_text)
      end

      def self.decrypt(key, text, appid)
        # 对解密后的明文进行补位删除
        # @param key: key
        # @param text: 密文
        # @return: 删除填充补位后的明文

        # 使用BASE64对密文进行解码
        text_in_aes = Base64.decode64(text)
        # 然后AES-CBC解密
        decipher = OpenSSL::Cipher::AES256.new(:CBC)
        decipher.decrypt
        decipher.padding = 0
        decipher.key = key
        decipher.iv = key[0..16]
        plain_text = decipher.update(text_in_aes) + decipher.final

        # 去掉补位字符串
        content = PKCS7Encoder.decode(plain_text)
        # 去除16位随机字符串
        content = content[16..-1]

        xml_len = content[0..4].unpack('N').first
        xml_content = content[4..(xml_len+4)]
        from_appid = content[(xml_len+4)..-1]
        if from_appid != appid
          raise WeixinMessageError, "wrong appid"
        end
        xml_content
      end

      def self.get_random_str
        # 随机生成16位字符串
        rand(36**16).to_s(36)
      end
    end

    class WXBizMsgCrypt
      # 构造函数
      # @param token: 公众平台上，开发者设置的token
      # @param encodingAESKey: 公众平台上，开发者设置的encodingAESKey
      # @param appid: appId
      attr_accessor :key, :token, :appid
      def initialize(token,encodingAESKey,appid)
        self.key = Base64.decode64(encodingAESKey+"=")
        self.token = token
        self.appid = appid
      end

      def EncryptMsg(sReplyMsg, sNonce, timestamp = nil)
        #将公众号回复用户的消息加密打包
        #@param sReplyMsg: 企业号待回复用户的消息，xml格式的字符串
        #@param sTimeStamp: 时间戳，可以自己生成，也可以用URL参数的timestamp,如为None则自动用当前时间
        #@param sNonce: 随机串，可以自己生成，也可以用URL参数的nonce
        #sEncryptMsg: 加密后的可以直接回复用户的密文，包括msg_signature, timestamp, nonce, encrypt的xml格式的字符串,
        encrypt = Prpcrypt.encrypt(self.key, sReplyMsg, self.appid)
        timestamp = Time.now.to_i if timestamp.nil?
        # 生成安全签名
        signature = SHA1.get(self.token, timestamp, sNonce, encrypt)
        # 生成XML
        XMLParse.generate(encrypt, signature, timestamp, sNonce)
      end

      def DecryptMsg(sPostData, sMsgSignature, sTimeStamp, sNonce)
        # 检验消息的真实性，并且获取解密后的明文
        # @param sMsgSignature: 签名串，对应URL参数的msg_signature
        # @param sTimeStamp: 时间戳，对应URL参数的timestamp
        # @param sNonce: 随机串，对应URL参数的nonce
        # @param sPostData: 密文，对应POST请求的数据
        #  xml_content: 解密后的原文，当return返回0时有效

        # 验证安全签名
        encrypt, _ = XMLParse.extract(sPostData)
        signature = SHA1.get(self.token, sTimeStamp, sNonce, encrypt)
        if signature != sMsgSignature
          raise WeixinMessageError, "wrong signature 签名错误"
        end
        xml_content = Prpcrypt.decrypt(self.key, encrypt, self.appid)
      end
    end

  end
end
