module Ddt
  class Printer
    module ManagedPrinter
      extend ActiveSupport::Concern
      included do
        include Ddt::PrinterModelName
        # validates_presence_of :token
      end

      def print(contents, times=nil, uuid: nil)
        times ||= self.times
        if contents.present?
          contents = contents.is_a?(Array) ? contents : [contents]
          index = 1
          contents.map do |content|
            if uuid.present?
              split_uuid = "#{uuid}-#{index}"
            else
              split_uuid = nil
            end
            index += 1
            record_id = send_to_print(content, times, uuid: split_uuid)
            if record_id.present?
              record = self.print_records.where(record_id: record_id).first
              if record.present?
                Rails.logger.error("duplicated record of record id #{record_id}")
              else
                self.print_records.create!(content: content, times: times, record_id: record_id)
              end
              true
            else
              false
            end
          end
        end
      end

      def send_to_print(content, times=1, uuid: nil)
        retry_with_times do
          response = Ddt::Printer::Api.send_post("/printers/print", {
                      printer_type: self.type_sym,
                      printer_code: self.number,
                      content: content,
                      times: times,
                      uuid: uuid
                    })
          response[:id]
        end
      end

      def get_state
        retry_with_times do
          response = Ddt::Printer::Api.send_get("/printers/get_state", {
                          printer_type: self.type_sym,
                          printer_code: self.number,
                        })
          response[:state]
        end
      end

      def get_print_record_state(print_record)
        response = Ddt::Printer::Api.send_get("/printers/get_print_record_state", { print_record_id: print_record.record_id })
        response[:state]
      end

      def clear_records
        retry_with_times do
          response = Ddt::Printer::Api.send_post("/printers/clear_records", {
                          printer_type: self.type_sym,
                          printer_code: self.number,
                        })
          response[:state]
        end
      end

      def is_managed?
        true
      end
    end
  end
end