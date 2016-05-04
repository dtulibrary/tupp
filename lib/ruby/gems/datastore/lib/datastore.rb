require 'bunny'
require 'json'

class Datastore

  def initialize(rabbitmq_url = ENV['RABBITMQ_URL'])
    @rabbitmq_url = rabbitmq_url
  end

  def export_events(options)
    raise unless block_given?

    conn = Bunny.new(@rabbitmq_url)
    conn.start

    ch = conn.create_channel
    
    req_x = ch.topic('dticds2topic', :durable => true)
    res_x = ch.direct(create_exchange_name(options), :auto_delete => true)
    res_q = ch.queue(res_x.name, :auto_delete => true, :exclusive => true)
    
    export_complete = false

    res_q.bind(res_x).subscribe do |delivery_info, metadata, data|
      case data
      when /"request":"eor"/
        export_complete = true
      else
        yield data
      end
    end

    export_request = create_export_request(options.merge(:exchange => res_x.name))
    req_x.publish(JSON.generate(export_request), :routing_key => 'export')

    sleep 1 until export_complete
  ensure
    conn.close unless conn.nil?
  end

  private

  def create_export_request(options)
    {
      'exchange'  => options[:exchange],
      'requestor' => 'tupp',
      'fromdate'  => options[:from],
      'untildate' => options[:until],
      'set'       => options[:set],
      'pkey'      => options[:pkey]
    }
      .reject {|k,v| v.nil?}
  end

  def create_exchange_name(options)
    {
      'request'   => 'export',
      'requestor' => 'tupp',
      'fromdate'  => options[:from],
      'untildate' => options[:until],
      'set'       => options[:set],
      'pkey'      => options[:pkey]
    }
      .reject {|k,v| v.nil?}
      .map    {|k,v| "#{k}=#{v}"}
      .join('&')
  end
end
