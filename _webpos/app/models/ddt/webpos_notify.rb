module Ddt
  module WebposNotify

    # msg_type: COOK_NOTIFICATION, CUSTOM_MESSAGE, VERIFY_VIPINFO
    def self.channel(account_id)
      "/webpos/messages/accounts/#{account_id}"
    end

    def self.verify_vip_info(qr_code_scene, vip_info)
      owner = qr_code_scene.owner
      terminal_id = qr_code_scene.preferred_terminal_id
      account_id = qr_code_scene.preferred_account_id
      msg = { type: "VERIFY_VIPINFO", vip_info: to_json(vip_info), terminal_id: terminal_id}
      publish_msg(account_id, msg)
    end

    def self.verify_vip_info_scan_success(qr_code_scene)
      terminal_id = qr_code_scene.preferred_terminal_id
      account_id = qr_code_scene.preferred_account_id
      msg = { type: "VERIFY_VIPINFO_SCAN_SUCCESS", terminal_id: terminal_id}
      publish_msg(account_id, msg)
    end

    def self.send_estimate_clear_msg(account_id, msg)
      publish_msg account_id, msg.merge(type: 'ESTIMATE_CLEAR')
    end

    def self.send_anti_settlement_msg(account_id, table, terminal_id)
      publish_msg(account_id, { type: 'TABLE_ANTI_SETTLEMENT', terminal_id: terminal_id, table_id: table.id})
    end

    private

    def self.publish_msg(account_id, msg)
      channel = self.channel(account_id)
      begin
        PrivatePub.publish_to(channel, msg: msg)
      rescue => e
        raise "WebsocketRails not start!: #{e}"
      end
    end

    def self.to_json(vip_info)
      return {
        id:                               vip_info.id,
        vip_no:                           vip_info.vip_no,
        vip_level_name:                   vip_info.vip_level_name,
        name:                             vip_info.name,
        phone:                            vip_info.phone,
        sex:                              vip_info.sex,
        discount:                         vip_info.discount,
        card_wallet:    { display_amount: vip_info.card_wallet.display_amount },
        credits_wallet: { display_amount: vip_info.credits_wallet.display_amount },
        is_default:                       vip_info.is_default
      }
    end

  end
end
