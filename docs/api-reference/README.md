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

### Retrieve a Cycle

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

### List Events
