module EmailEvents::Adapters
  module Abstract
    class EventData
      [:event_type, :event_timestamp, :recipient, :status_string, :smtp_status_code, :reason,
       :smtp_message_id, :provider_message_id, :simplified_status, :raw_data].each do |pure_virtual_method|
        define_method(pure_virtual_method) { raise "Not implemented" }
      end

      def simplified_status
        # try to get a specific status based on the smtp status code; however, if the event doesn't have an smtp
        # status code (eg. bounce events always do, but drop events only do sometimes), supply a generic one
        return :unable_to_send_email_to_address_provided if smtp_status_code.blank?

        case smtp_status_code
        when 510, 511, 512
          :email_address_invalid
        when 523
          :email_exceeds_recipients_size_limit
        when 541
          :email_rejected_as_spam
        when 552
          :recipients_inbox_is_full
        else
          :unknown
        end
      end
    end
  end
end

