# example-cirro-rails-app

### Requirements

- ruby 2.7.1p83
- bundler 2.1.4
- mysql 14.14
- nodejs 14.4.0 or higher
- yarn 1.22.4 or higher

### Setup
```bash
git clone https://github.com/test-IO/example-cirro-rails-app
cd example-cirro-rails-app && yarn install && bin/setup
```

### Connection with cirro locally

* Register a new app here -> http://developers.app.localhost:3000//apps/new
* Enter the callback url as `https://localhost:3001/users/auth/cirro/callback`
* Put the app_id and app_secret as env variables https://github.com/test-IO/example-cirro-rails-app/blob/master/config/settings.yml
* Keep the private key generated as key.pem above in root directory of this project locally (https://github.com/test-IO/example-cirro-rails-app/blob/master/app/services/cirro_client/jwt_authentication.rb)


### Run the servers locally
```bash
bin/rails s
bin/webpack-dev-server
```

### Key files for integration with Cirro

1. `lib/omniauth/strategies/cirro.rb`

Cirro provides, first and foremost, an OAuth sign in flow for your users. In this Ruby on Rails application, we make use of the [Devise gem](https://github.com/plataformatec/devise) and its [integration with OmniAuth](https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview) to wire up this OAuth flow. Our custom OmniAuth strategy lives in `lib/omniauth/strategies/cirro.rb` and is "plugged into" the `User` model via the `devise :omniauthable, omniauth_providers: %i[cirro]`. We then wire up the routes via Devise's routes helper:

```ruby
devise_for :users, controllers: {
	omniauth_callbacks: 'users/omniauth_callbacks'
}
```

2. `app/controllers/users/omniauth_callbacks_controller.rb`

The Devise routes helper above will setup the required routes for the OAuth flow, but we need to manually determine what happens at the end of that flow; that is, when Cirro redirects the authenticated user back to our application. The `Users::OmniauthCallbacksController#cirro` controller action defines precisely what happens at this point in the flow. We use a `User.from_omniauth` method to find or create an appropriate `User` record, then use a `User#update_cirro_access_token` method to ensure we store the up-to-date version of this user's Cirro access token. This user access token is necessary for any Cirro API calls we wish to make _on the user's behalf_ (instead of the more typical case of making Cirro API calls _on the application's behalf_).


3. `config/settings.yml` and `config/settings/*.yml`

We make use of a gem called [`Config`](https://github.com/rubyconfig/config) to provide a globally available `Settings` object, where we can store key data about the Cirro platform. This `Settings` object is even used in configuring the custom Cirro OmniAuth strategy above. Matching the data with your Space's credentials provided when registering with the Cirro platform is essential to getting this app up and running. To get this application successfully deployed, you will need to manage the ENV variables that `config/settings/production.yml` expects: `CIRRO_APP_ID` and `CIRRO_APP_SECRET`. You will also need to update the `host` settings value appropriately.

4. `config/initializers/cirro_ruby_client.rb`

In order to make working with the Cirro API as straightforward as possible, we provide a [Ruby wrapper gem](https://github.com/test-IO/cirro-ruby-client) which exposes an object-oriented interface for the Cirro API. This gem must be appropriately configured, which is handled by this initializer file. Once configured, we can then use the gem anywhere in our application to access the the Cirro API.

5. `app/controllers/translation_assignments_controller.rb`

The primary use of the `CirroIO::Client` gem can be found in this controller, which provides the application root route as well (`root to: "translation_assignments#index"`). You will note a before action (`before_action :fetch_app_worker`) which makes a Cirro API call at the outset of every request that this controller handles. This API call fetches the Cirro `AppWorker` record for the authenticated `User`. For more information on the difference and relationships between a Space's `User`, Cirro's `AppUser`, and Cirro's `AppWorker`, please read the appropriate section of the "Getting Started Guide". As a summary, only `AppWorker`s can receive gig invitations, and Spaces must manually promote `AppUser`s to become `AppWorker`s.

6. `app/controllers/application_controller.rb`

So, how does this demo application promote `AppUser`s to `AppWorker`s? To answer this question, we need first to return to the `ApplicationController`, where we define a Devise hook: `after_sign_in_path_for`. Devise allows applications to determine where users are redirected to after they successfully authenticate. Since the only way for users to sign into this application is using Cirro as an OAuth provider, this hook determines where users are taken after the `Users::OmniauthCallbacksController#cirro` controller action. You will see that in our `after_sign_in_path_for` method we either send users to `edit_user_path` or `translation_assignments_path` (as `root_path`). The determining factor is whether or not the newly authenticated user has any `languages` and `domains` set for their profile. When a new user signs up and the `User.from_omniauth` method called from the `Users::OmniauthCallbacksController#cirro` controller action _creates_ a new `User` record, these fields will be blank. In this case, we take users to the page where they can set this information. This is the essential detail in the flow for promoting `AppUser`s to `AppWorker`s. In order for a user to receive gig invitations, we need to have the required profile information to match them to appropriate gigs. Therefore, a user cannot become an `AppWorker` until they provide us with this required information.

7. `app/models/user.rb`

When a user updates their profile with their languages and domains, we need to be sure to actually promote them to an `AppWorker`. This is accomplished via the `create_or_update_app_worker` callback method in the `User` model. We define a callback that fires on any update to a `User` record. This method then ensures that either `languages` or `domains` were updated. If they were, we need to be sure to either promote the `AppUser` to become a new `AppWorker` or to update the existing `AppWorker` with the newly updated data; that is, we are either creating or updating a Cirro `AppWorker` record.

8. `app/models/translation_assignment.rb`

Once a Space has enough `AppWorker`s to receive gig invitations, it needs to be able to create Cirro `Gig`s. In this example application, Cirro `Gig`s map to `TranslationAssignments`, which can be created by "admins" in the admin portal (`/admin/translation_assignments/new`). The important detail for the integration with Cirro is not this form tho, it is the API call required to sync this newly created `TranslationAssignment` to Cirro as a `Gig`. This is handled again via a model callback (`create_gig_with_tasks_and_invitation_filter`) scoped to create. As you should already have seen from the API documentation, the simplest way to create a `Gig` with all of its required associated records (`GigTask`s and `WorkerFilter`s) is the "bulk create" endpoint. The `CirroIO::Client` gem exposes this as a `Gig#bulk_create_with` method. As you can see in the method in the source, we initialize a `GigTask` object, a `WorkerFilter` object, and a `Gig` object. We can then use these Ruby objects via the `CirroIO::Client` gem to make the appropriate "bulk create" API call. Thus, whenever a `TranslationAssignment` is created, an appropriately matching Cirro `Gig` is also created.

> **Note:** This implementation is kept intentionally simple to reduce "noise" in providing an example of how to integrate with the Cirro platform; however, in a real application, any such Cirro API calls should be made within `ActiveJob` classes to ensure that any HTTP failures can be handled and the request automatically retried. As it stands, this example code is prone to failure as any API call that fails for any reason has no mechanism to ever be retried. `ActiveJob` is a wonderful way to wrap write API calls, as it provides retries "for free".

9. `app/controllers/translation_assignments_controller.rb`

Once a Cirro `Gig` has been created, Cirro will automatically begin finding and inviting `AppWorker`s that match the gig's `WorkerFilter`. Our Space needs to ensure that only invited Workers are granted access to the `TranslationAssignment`. In this example app, this authorization is managed directly in the `TranslationAssignmentsController` using a `before_action` and a check in the `#show` action. The `fetch_assignment` before action takes advantage of the API call made in the previously executed `fetch_app_worker` before action to check if any of the current worker's `gig_invitations` match the `TranslationAssignment` being requested. In the `#show` action, we guard against no `gig_invitation` being found or the gig invitation being rejected. 

> **Note::** This is another example of a purposely ver simplistic implementation of integrating Space resource authorization with Cirro. Relying on successful HTTP requests and having no mechanism to tell the user that they may simply be "too fast" in checking the Space makes this solution not ideal for a production application. One possible alternative would be to have a polling job that regularly checks and syncs Cirro's `gig_invitation`s into the Space database, then allowing the rest of the application to use more standard authorization patterns.

10. `app/controllers/translation_assignments_controller.rb`

When a Worker has access to an assignment, they need to then decide whether they will accept or reject the `gig_invitation`. What information you display to the Worker to help them determine if this is work they want to take on or not is up to the Space, but all Spaces will need to tell Cirro when a Worker either accepts or rejects the invitation. In this example Space, we expose two custom actions from the `TranslationAssignmentsController` (`#accept` and `#reject`) which are connected to two tiny `<form>`s rendered in the show view. Each action simply makes the appropriate Cirro API call using the `CirroIO::Client` gem. What is important is _how_ the API calls are made, but _that_ the API calls are made. Cirro must be made aware of which Workers need to be assigned to the Gig.

11. `app/controllers/translation_results_controller.rb`

The final phase in the lifecycle of a Gig focuses on the results. Which workers did what tasks taking how much time? Cirro needs to know both which `GigTask`s were performed by a particular Worker for a particular Gig (creating a `GigResult` resource), but also how long a particular Worker spent on a particular Gig (creating a `GigTimeActivity` resource). This allows Cirro to properly compensate both EPAM employees and external freelancers, without your Space needing to know which Workers are which type. However, in order to report `GigTimeActivity` your Space will need to perform at least basic time tracking. In this example Space, we track simply the time the Workers starts translating a particular file and the moment they submit their translation. A "Start translating" button shown on the `TranslationAssignment#show` page after the `gig_invitation` is accepted creates a new `TranslationResult` record, noting the timestamp of this action in the `started_at` field. We then use a basic state machine on the `TranslationResult` model to determine how to evolve the view of the `TranslationAssignment#show` page.

12. `app/controllers/translation_results_controller.rb`

Obviously, the second essential part of basic time tracking is tracking the time the work is _done_. In this example Space, `TranslationResultsController#update` manages this responsibility, leaning on the state machine defined for the `TranslationResult` model.

13. `app/controllers/admin/translation_results_controller.rb`

Once a Worker has submitted a translation of a particular file, we ask admins to review the translation and accept or reject it, to ensure that our customers always see translations verified by an admin. This kind of second layer verification of crowd-driven services is a common approach to helping assure quality results for customers. This feature does not require any synchronization with Cirro, however.

14. `app/models/translation_assignment.rb`

Cirro only needs to know about things once the Gig is done. In the case of this example Space, admins can "archive" the Gig once all requested files for the translation gig have a translation submitted by a Worker and verified by an admin. When an admin marks a `TranslationAssignment` as `archived`, this is when we report the results of this Gig to Cirro. The state machine defined for `TranslationAssigment`s sets up a hook such that when an assignment is archived, the `archive_gig` method is called, which is where the Cirro API integration is defined. As you will find in that method, we loop over all of the `TranslationResult` records for this assignment and initialize the appropriate `GigResult` and `GigTimeActivity` resources. We can then use the `bulk_archive_with` method defined for `CirroIO::Client::Gig` to report all of the appropriate data to Cirro in one API call.

With our `Gig` now archived and reported, the lifecycle of a Gig is now complete. For this example Space, there are no other key integrations with the Cirro platform. Hopefully, this walkthru of how this Rails application integrates with Cirro has helped you better understand how you can and should integrate with Cirro for your next crowd-driven service application.
