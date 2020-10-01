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

      # example for payload:
      # {
      #    "data":{
      #       "relationships":{
      #          "gig_results":[
      #             {
      #                "app_worker_id":4,
      #                "title":"Modern Times",
      #                "description":"Here's looking at you, kid.",
      #                "quantity":2
      #             }
      #          ],
      #          "gig_time_activities":[
      #             {
      #                "app_worker_id":4,
      #                "description":"What we've got here is failure to communicate.",
      #                "date":"2022-01-01T01:00:00.000Z",
      #                "duration_in_ms":360000
      #             }
      #          ]
      #       }
      #    }
      # }

      def self.bulk_archive(gig_id, payload)
        url = "#{SITE}/gigs/#{gig_id}/archive"
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
