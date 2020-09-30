module CirroClient
  module BulkActions
    class Gig < Base
      # example for payload:
      # {
      #   data: {
      #     attributes: {
      #       title: 'New Gig',
      #       description: 'This is a test gig',
      #       url: 'www.example.com',
      #       total_seats: 10,
      #       automatic_invites: true,
      #       archive_at: 1.month.from_now,
      #     },
      #     relationships: {
      #       worker_invitation_filter: { filter_query: '{}' },
      #       gig_tasks: [
      #         { title: 'TranslationAssignment', base_price: 500 }
      #       ]
      #     }
      #   }
      # }
      def self.bulk_create(payload)
        url = "#{SITE}/gigs"
        response = Faraday.post(url, payload.to_json, **headers)

        if response.status == 201
          JSON.parse(response.body)['data']
        else
          nil
        end
      end
    end
  end
end
