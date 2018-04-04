# pings-rb

#### Installation Guide
1. Install sinatra by running `gem install sinatra` in your command line.
2. Install mysql2 by running `gem install mysql2` in your command line.
3. Change `pings.rb` BASE_URL to point to `localhost:4567`
4. Create database named `tanda`.
5. Create table named pings with `device_id` varchar(255) and `epoch_time` int.
6. Run app using `ruby app.rb`
