json.extract! event, :id,
                     :block_id,
                     :related_block_id,
                     :sender_id,
                     :sender_name,
                     :receiver_id,
                     :receiver_name,
                     :reward,
                     :priority,
                     :slot
json.type event.type.demodulize.underscore
