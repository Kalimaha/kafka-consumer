# Kafka Consumer

This app is based on [Karafka](https://github.com/karafka/karafka) and is
composed by a main server and a workers queue.

The main server pulls continuosly from Kafka and enqueues one job per message
_(generated and handled by the `karafka-sidekiq-backend` extension)_ that is 
then processed by the business logic defined in `/consumers`:

```ruby
topic :orders do
  consumer BatchConsumer
  backend :sidekiq
  worker ApplicationWorker
end
```

At runtime, the server will log something like this:

```bash
I, [2020-10-09T09:37:44.407621 #49706]  INFO -- : 1 messages on orders topic delegated to BatchConsumer
```

and the queue will process the job like:

```ruby
<== == == BATCH CONSUMER - START == == ==>
  Message Received:
  -----------------
    KEY: 88ad2b37-fd60-45e5-8da1-0e55f929cee8
  VALUE: {"status"=>"in_progress", "centsPrice"=>6927, "currency"=>"AUD", "lineItems"=>[{"itemId"=>"3f80f054-07bb-42f8-b896-00efcb6339b4", "name"=>"Bruschette with Tomato", "quantity"=>2, "centsPrice"=>1923, "currency"=>"AUD"}, {"itemId"=>"3458fa4d-2836-4395-9fa4-160dc433c112", "name"=>"Peking Duck", "quantity"=>2, "centsPrice"=>901, "currency"=>"AUD"}, {"itemId"=>"b2d8255c-7d19-4b94-8cd2-670303a74cae", "name"=>"French Fries with Sausages", "quantity"=>2, "centsPrice"=>1990, "currency"=>"AUD"}, {"itemId"=>"0545c88c-c9e5-4a95-8f22-afbdb5d43ae7", "name"=>"Fish and Chips", "quantity"=>3, "centsPrice"=>2113, "currency"=>"AUD"}], "createdAt"=>"2020-10-08 22:37:41 UTC", "updatedAt"=>"2020-10-08 22:37:41 UTC", "customerName"=>"Rep. Fransisca Larson", "customerAddress"=>"81415 Bruen Pike", "customerSuburb"=>"Richmond", "customerPostcode"=>"3121", "customerState"=>"WA", "customerEmail"=>"marcelo@willms-hilll.biz", "customerPhone"=>"490.374.2410 x57832"}
<== == == BATCH CONSUMER -  END  == == ==>
```

The workers queue is a simple Sidekiq instance backed by Redis.

## Start the server

```bash
bundle exec karafka s
```

## Start the workers

```bash
bundle exec karafka w
```

## CloudKarafka

Kafka is hosted by [CloudKarafka](https://customer.cloudkarafka.com/instance)
and the main app pulls from the `orders` topic.
