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
cd example-cirro-rails-app && bin/setup
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
