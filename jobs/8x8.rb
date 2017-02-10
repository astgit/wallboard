require 'curb'
require 'nokogiri'

SCHEDULER.every '15s', :first_in => 0 do |job|

    c = Curl::Easy.new("https://vcc-eu2.8x8.com/api/rtstats/stats/queues")
    c.http_auth_types = :basic
    c.username = "castletrust"
    c.password = "673a56fe47c3fade7487b5182d3ba05c"
    c.perform
    xmlstring = c.body_str

    @xml_doc = Nokogiri::XML(xmlstring)

    lending_queues = ["Post Completion", "Pre-Completion", "Mailshot"]

    set :lending_position_8x8, ! defined?(settings.lending_position_8x8) || settings.lending_position_8x8 >= lending_queues.length ? 1 : settings.lending_position_8x8 + 1

    lending_queue = lending_queues[settings.lending_position_8x8 - 1]
    sales_queue   = "Telesales"

    status_limits = {
        :num_agents_avail => proc { |n|
            if n > 2 then :ok
            elsif n > 0 then :warning
            else :critical
            end
        },
        :num_callers_in_queue => proc { |n|
            if n > 10 then :critical
            elsif n > 5 then :warning
            else :ok
            end
        },
        :avg_wait_time => proc { |n|
            if n > 90 then :critical
            elsif n > 25 then :warning
            else :ok
            end
        },
        :total_abandoned => proc { |n|
            if n > 4 then :critical
            elsif n > 2 then :warning
            else :ok
            end
        },
    }

    lending_stats = {
        :num_agents_avail => @xml_doc.xpath("/queues/queue[queue-name='#{lending_queue}']/agent-count-waitTransact").text.to_i,
        :num_callers_in_queue => @xml_doc.xpath("/queues/queue[queue-name='#{lending_queue}']/queue-size").text.to_i,
        :avg_wait_time => @xml_doc.xpath("/queues/queue[queue-name='#{lending_queue}']/day-avg-wait-time").text.to_i,
        :total_queued => @xml_doc.xpath("/queues/queue[queue-name='#{lending_queue}']/day-queued").text.to_i,
        :total_accepted => @xml_doc.xpath("/queues/queue[queue-name='#{lending_queue}']/day-accepted").text.to_i,
        :total_abandoned => @xml_doc.xpath("/queues/queue[queue-name='#{lending_queue}']/day-abandoned").text.to_i
    }

    sales_stats = {
        :num_agents_avail => @xml_doc.xpath("/queues/queue[queue-name='#{sales_queue}']/agent-count-waitTransact").text.to_i,
        :num_callers_in_queue => @xml_doc.xpath("/queues/queue[queue-name='#{sales_queue}']/queue-size").text.to_i,
        :avg_wait_time => @xml_doc.xpath("/queues/queue[queue-name='#{sales_queue}']/day-avg-wait-time").text.to_i,
        :total_queued => @xml_doc.xpath("/queues/queue[queue-name='#{sales_queue}']/day-queued").text.to_i,
        :total_accepted => @xml_doc.xpath("/queues/queue[queue-name='#{sales_queue}']/day-accepted").text.to_i,
        :total_abandoned => @xml_doc.xpath("/queues/queue[queue-name='#{sales_queue}']/day-abandoned").text.to_i
    }

    lending_stats.each do |type, value|
        message = {}

        if status_limits.key?(type)
            if (type === :avg_wait_time)
                message = { message: value, status: status_limits[type].call(value), subtitle: "(in seconds)" }
            else
                message = { message: value, status: status_limits[type].call(value) }
            end
        else
            message = { current: value }
        end

        send_event("lending_#{type}", message)
    end

    sales_stats.each do |type, value|
        message = {}

        if status_limits.key?(type)
            if (type === :avg_wait_time)
                message = { message: value, status: status_limits[type].call(value), subtitle: "(in seconds)" }
            else
                message = { message: value, status: status_limits[type].call(value) }
            end
        else
            message = { current: value }
        end

        send_event("sales_#{type}", message)
    end

    send_event("lending_queue_name", {title: "Lending (#{lending_queue})"})
end
