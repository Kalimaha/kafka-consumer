# frozen_string_literal: true

class BatchConsumer < ApplicationConsumer
  def consume
    puts "<== == == BATCH CONSUMER - START == == ==>"
    params_batch.each do |param|
      puts "\tMessage Received:"
      puts "\t-----------------"
      puts "\t  KEY: #{param.payload['key']}" 
      puts "\tVALUE: #{param.payload['value']}" 
    end
    puts "<== == == BATCH CONSUMER -  END  == == ==>"
  end
end
