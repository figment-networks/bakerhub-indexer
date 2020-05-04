---
sidebar: auto
sidebarDepth: 2
---

# API Reference

## Note about API Client

Currently the client code is in BakerHub. You can still make requests directly to the API, but the code samples in these API Docs won't work unless we pull the client code out as a separate gem.

## Bakers

### List Bakers <Badge text="GET"/>

`https://bakerhub-indexer.figment.network/tezos/bakers`

Returns a list of all Bakers

**Query Params**

Param | Type | Notes
------|------|------
query | string | Search Bakers by name or address

```ruby
# List all Bakers
Indexer::Baker.list()

# With a search query
Indexer::Baker.list(query: "Figment")
```

**Example Response**

```js
[
  {"id":"tz2Q7Km98GPzV1JLNpkrQrSo5YUhPfDp6LmA","name":null,"url":"https://bakerhub-indexer.figment.network/tezos/bakers/tz2Q7Km98GPzV1JLNpkrQrSo5YUhPfDp6LmA"},
  {"id":"tz2KuCcKSyMzs8wRJXzjqoHgojPkSUem8ZBS","name":null,"url":"https://bakerhub-indexer.figment.network/tezos/bakers/tz2KuCcKSyMzs8wRJXzjqoHgojPkSUem8ZBS"},
  {"id":"tz2KrmHRWu7b7Vr3GYQ3SJ41xaW64PiqWBYm","name":null,"url":"https://bakerhub-indexer.figment.network/tezos/bakers/tz2KrmHRWu7b7Vr3GYQ3SJ41xaW64PiqWBYm"},
  {"id":"tz2JMPu9yVKuX2Au8UUbp7YrKBZJSdYhgwwu","name":null,"url":"https://bakerhub-indexer.figment.network/tezos/bakers/tz2JMPu9yVKuX2Au8UUbp7YrKBZJSdYhgwwu"},
  {"id":"tz2E3BvcMiGvFEgNVdsAiwVvPHcwJDTA8wLt","name":null,"url":"https://bakerhub-indexer.figment.network/tezos/bakers/tz2E3BvcMiGvFEgNVdsAiwVvPHcwJDTA8wLt"}
]
```

### Retrieve a Baker <Badge text="GET"/>

`https://bakerhub-indexer.figment.network/tezos/bakers/:id`

Get details about a single Baker

**Path Params**

Param | Type | Notes
------|------|------
id * | string | Baker address

```ruby
Indexer::Baker.retrieve("tz1Scdr2HsZiQjc7bHMeBbmDRXYVvdhjJbBh")
```

**Example Response**

```js
{
  "id": "tz2Q7Km98GPzV1JLNpkrQrSo5YUhPfDp6LmA",
  "name": null,
  "url": "http://localhost:3000/tezos/bakers/tz2Q7Km98GPzV1JLNpkrQrSo5YUhPfDp6LmA",
  "lifetime_baking_stats": {
    "blocks_baked": 11,
    "blocks_missed": 0,
    "blocks_stolen": 0
  },
  "lifetime_endorsing_stats": {
    "total_slots": 403,
    "endorsed_slots": 402
  },
  "baking_stats_history": {
    "0": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "1": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "2": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "3": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "4": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "5": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "6": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "7": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "8": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "9": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    },
    "10": {
      "blocks_baked": 0,
      "blocks_missed": 0,
      "blocks_stolen": 0
    }
  },
  "endorsing_stats_history": {
    "0": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "1": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "2": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "3": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "4": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "5": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "6": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "7": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "8": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "9": {
      "total_slots": 0,
      "endorsed_slots": 0
    },
    "10": {
      "total_slots": 0,
      "endorsed_slots": 0
    }
  }
}
```

## Cycles

### Retrieve a Cycle <Badge text="GET"/>

`https://bakerhub-indexer.figment.network/tezos/cycles/:id`

Get details about a single Cycle

**Path Params**

Param | Type | Notes
------|------|------
id * | string | Cycle number. Can also be `current` (default) or `latest_completed`

```ruby
Indexer::Cycle.retrieve("225")
```

**Example Response**

```js
{
  "number": 226,
  "snapshot_cycle_number": 219,
  "snapshot_height": 898048,
  "rewards_unfrozen_cycle_number": 231,
  "total_rolls": 81039,
  "start_height": 925697,
  "end_height": 929792,
  "cached_baking_stats": {
    ...
  },
  "cached_endorsing_stats": {
    ...
  },
  "start_time": 1587872635,
  "end_time": 1588118716,
  "seconds_remaining": 0,
  "blocks_left": 0,
  "missed_priorities": 8,
  "missed_slots": 506,
  "url": "https://bakerhub-indexer.figment.network/tezos/cycles/226"
}
```

## Events

### List Events <Badge text="GET"/>

`https://bakerhub-indexer.figment.network/tezos/(:cycle_id)/events`

List Tezos Events

**Path Params**

Param | Type | Notes
------|------|------
cycle_id | integer | ID of the cycle you would like Events for

**Query Params**

Param | Type | Notes
------|------|------
page | integer | Page number to retrieve if pagination is enabled
paginate | string | If set to "false" results will not be paginated
after_height | integer | Scope to Events related to Blocks with a height greater than the given value
after_timestamp | integer | Scope to Events related to Blocks with a timestamp after the given value
types | array | Scope to Events with the given types. Possible values are `missed_bake`, `missed_endorsement`, `steal`, `double_bake`, `double_endorsement`

Note: Pagination data in result is generated by the `pagy` ruby gem and can be used by the client app to create a Pagy object

```ruby
@events = Indexer::Event.list(cycle_id: @cycle.number, page: params[:page])
@pagy = Pagy.new(@events[:pagination].symbolize_keys)
```

**Example Response**

```js
{
  "events": [
    {
      "id": 2615,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931965,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 10
    },
    {
      "id": 2616,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931965,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 29
    },
    {
      "id": 2614,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931963,
      "related_block_id": null,
      "sender_id": "tz1MQJPGNMijnXnVoBENFz9rUhaPt3S7rWoz",
      "sender_name": "Tezmania",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 3
    },
    {
      "id": 2613,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931960,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 3
    },
    {
      "id": 2612,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931952,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 13
    },
    {
      "id": 2611,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931947,
      "related_block_id": null,
      "sender_id": "tz1NEKxGEHsFufk87CVZcrqWu8o22qh46GK6",
      "sender_name": "Money Every 3 Days",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 19
    },
    {
      "id": 2610,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931945,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 1
    },
    {
      "id": 2609,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931940,
      "related_block_id": null,
      "sender_id": "tz1NEKxGEHsFufk87CVZcrqWu8o22qh46GK6",
      "sender_name": "Money Every 3 Days",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 25
    },
    {
      "id": 2608,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931938,
      "related_block_id": null,
      "sender_id": "tz1hTFcQk2KJRPzZyHkCwbj7E1zY1xBkiHsk",
      "sender_name": "ownBLOCK",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 25
    },
    {
      "id": 2607,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931937,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 27
    },
    {
      "id": 2603,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931935,
      "related_block_id": null,
      "sender_id": "tz3RB4aoyjov4KEVRbuhvQ1CKJgBJMWhaeB8",
      "sender_name": null,
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 13
    },
    {
      "id": 2604,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931935,
      "related_block_id": null,
      "sender_id": "tz3RB4aoyjov4KEVRbuhvQ1CKJgBJMWhaeB8",
      "sender_name": null,
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 20
    },
    {
      "id": 2605,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931935,
      "related_block_id": null,
      "sender_id": "tz3RB4aoyjov4KEVRbuhvQ1CKJgBJMWhaeB8",
      "sender_name": null,
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 26
    },
    {
      "id": 2606,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931935,
      "related_block_id": null,
      "sender_id": "tz3VEZ4k6a4Wx42iyev6i2aVAptTRLEAivNN",
      "sender_name": null,
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 30
    },
    {
      "id": 2145,
      "type": "Tezos::Event::Steal",
      "block_id": 931931,
      "related_block_id": null,
      "sender_id": "tz1irJKkXS2DBWkU1NnmFQx1c1L7pbGg4yhk",
      "sender_name": "Coinbase",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": null
    },
    {
      "id": 2146,
      "type": "Tezos::Event::MissedBake",
      "block_id": 931931,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": 0,
      "slot": null
    },
    {
      "id": 2601,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931930,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 13
    },
    {
      "id": 2602,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931930,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 30
    },
    {
      "id": 2600,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931928,
      "related_block_id": null,
      "sender_id": "tz1MQJPGNMijnXnVoBENFz9rUhaPt3S7rWoz",
      "sender_name": "Tezmania",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 14
    },
    {
      "id": 2599,
      "type": "Tezos::Event::MissedEndorsement",
      "block_id": 931925,
      "related_block_id": null,
      "sender_id": "tz1VQnqCCqX4K5sP3FNkVSNKTdCAMJDd3E1n",
      "sender_name": "",
      "receiver_id": null,
      "receiver_name": null,
      "reward": null,
      "priority": null,
      "slot": 29
    }
  ],
  "pagination": {
    "vars": {
      "page": 1,
      "items": 20,
      "outset": 0,
      "size": [
        1,
        4,
        4,
        1
      ],
      "page_param": "page",
      "params": {},
      "anchor": "",
      "link_extra": "",
      "i18n_key": "pagy.item_name",
      "cycle": false,
      "count": 2616
    },
    "count": 2616,
    "items": 20,
    "outset": 0,
    "page": 1,
    "last": 131,
    "pages": 131,
    "offset": 0,
    "from": 1,
    "to": 20,
    "prev": null,
    "next": 2
  }
}
```
