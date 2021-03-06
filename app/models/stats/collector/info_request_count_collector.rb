module Stats
  module Collector
    # This class counts the number of claims authorised today where the caseworker requested
    # extra information -vs- the number that were authorised without further info being needed.
    #
    class InfoRequestCountCollector < BaseCollector
      def collect
        count = claims_authorised_without_further_info_requested_count
        Statistic.create_or_update(@date, 'claims_authorised_without_further_info', 'Claim::BaseClaim', count)

        count = claims_authorised_after_further_info_requested_count
        Statistic.create_or_update(@date, 'claims_authorised_after_info_requested', 'Claim::BaseClaim', count)
      end

      private

      def claims_authorised_without_further_info_requested_count
        sql = "
          select
            date(c.authorised_at),
            count(*)
          from claims c
          left outer join messages m on (m.claim_id = c.id)
          left outer join users u on (m.sender_id = u.id)
          where c.authorised_at between '#{@beginning_of_day}' and '#{@end_of_day}'
          and (u.persona_type is null or u.persona_type !='ExternalUser')
          and m.id is null
          group by date(c.authorised_at)
        "
        execute_query(sql)
      end

      def claims_authorised_after_further_info_requested_count
        sql = "
          select
            distinct(c.id),
            date(c.authorised_at),
            count(m.id)
          from claims c
          left outer join messages m on (m.claim_id = c.id)
          inner join users u on (m.sender_id = u.id)
          where c.authorised_at between '#{@beginning_of_day}' and '#{@end_of_day}'
          and (u.persona_type is null or u.persona_type !='ExternalUser')
          and m.id is not null
          and m.body not ilike 'paid in full'
          group by c.id
          having count(m.id) = 1
        "
        execute_query(sql)
      end

      def execute_query(sql)
        result_set = ActiveRecord::Base.connection.execute(sql)
        result_set.reduce(0) { |a, e| a + e['count'].to_i }
      end
    end
  end
end
