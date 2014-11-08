---
layout: card
title: "Twitter"
---

[Twitter](http://www.twitter.com/) is a social networking and microblogging service. Twitter does store tweets only for a limited amount of time, so it is up to us to collect this information regularly. We therefore store all information internally in a CouchDB database (defined by the `data_url` configuration).

## Authentication
[Application-only authentication](https://dev.twitter.com/docs/auth/application-only-auth) is the preferred method of authentication because the authentication process is simpler and the rate-limits are higher. Application-only authentication uses OAuth2 and the first step is to register your application at the [Twitter Developer website](https://dev.twitter.com/apps) and obtain an `API key` and `API secret` (they are found under the `API Keys` tab).

Please enter `API key` and `API secret` in the ALM configuration settings. The application will automatically fetch and store an OAuth2 `access token` the first time we use the source. To obtain the `access token` yourself, issue the following command:

```sh
curl -u API_KEY:API_SECRET -d grant_type=client_credentials https://api.twitter.com/oauth2/token
```

## Required configuration fields

* **api_key** and **api_secret**: available via https://dev.twitter.com/apps.

## Query
The source searches the Twitter Search API by DOI and URL, e.g. `10.1371/journal.pmed.0020124 OR http://www.plosmedicine.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124`. The Search API will find shortened URLs with this query.

## Rate-Limiting
The rate-limits for application-only authentication and search are 450 requests per 15 min or 1,800 requests per hour. Depending on the number of articles we might have to adjust how often we contact Twitter, the default settings are every 12 hours the first 7 days after publication, then daily for the first month, and then weekly.

<table width=100% border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td valign="top" width=30%><strong>ALM Name</strong></td>
<td valign="top" width=70%>twitter_search</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Configuration</strong></td>
<td valign="top" width=80%>default</td>
</tr>
<tr>
<td valign="top" width=20%><strong>ALM Core Attributes</strong></td>
<td valign="top" width=80%>id<br/>url<br/>user<br/>date (as created_at)</td>
</tr>
<td valign="top" width=20%><strong>ALM Other Attributes</strong></td>
<td valign="top" width=80%>title</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Protocol</strong></td>
<td valign="top" width=70%>REST</td>
</tr>
<tr>
<td valign="top" width=30%><strong>Format</strong></td>
<td valign="top" width=70%>JSON</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Rate-limiting</strong></td>
<td valign="top" width=80%>1,800/hr</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Authentication</strong></td>
<td valign="top" width=80%>OAuth2</td>
</tr>
<tr>
<td valign="top" width=20%><strong>Restriction by IP Address</strong></td>
<td valign="top" width=80%>no</td>
</tr>
<tr>
<td valign="top" width=20%><strong>API URL</strong></td>
<td valign="top" width=80%>https://api.twitter.com/1.1/search/tweets.json?q=URL</td>
</tr>
<tr>
<td valign="top" width=20%><strong>License</strong></td>
<td valign="top" width=80%><a href="https://twitter.com/tos">Terms of Service</a></td>
</tr>
</tbody>
</table>

## Example Response

```json
{
  "statuses": [
    {
      "metadata": {
        "result_type": "recent",
        "iso_language_code": "en"
      },
      "created_at": "Sat Jan 11 22:30:50 +0000 2014",
      "id": 422133526704979968,
      "id_str": "422133526704979968",
      "text": "RT @conradhackett: Twitter users per capita\n1 Kuwait\n2 N-lands\n3 Brunei\n4 UK\n5 US\n6 Chile\n7 Ireland\nhttp://t.co/j1wQ5fbtkQ\n2010-12 data\nhtt…",
      "source": "<a href=\"http://twitter.com/download/android\" rel=\"nofollow\">Twitter for Android</a>",
      "truncated": false,
      "in_reply_to_status_id": null,
      "in_reply_to_status_id_str": null,
      "in_reply_to_user_id": null,
      "in_reply_to_user_id_str": null,
      "in_reply_to_screen_name": null,
      "user": {
        "id": 328957205,
        "id_str": "328957205",
        "name": "Mohamad Al-Awadhi",
        "screen_name": "i486DX2WB",
        "location": "Kuwait City/Al-Rowda",
        "description": "Well Surveillance '08, Deep Drilling '10, MS&R '12, Gas Operations '13 (S&EK), @KOCOfficial",
        "url": null,
        "entities": {
          "description": {
            "urls": [
            ]
          }
        },
        "protected": false,
        "followers_count": 142,
        "friends_count": 74,
        "listed_count": 1,
        "created_at": "Mon Jul 04 09:57:16 +0000 2011",
        "favourites_count": 6,
        "utc_offset": null,
        "time_zone": null,
        "geo_enabled": true,
        "verified": false,
        "statuses_count": 3233,
        "lang": "en",
        "contributors_enabled": false,
        "is_translator": false,
        "profile_background_color": "C0DEED",
        "profile_background_image_url": "http://abs.twimg.com/images/themes/theme1/bg.png",
        "profile_background_image_url_https": "https://abs.twimg.com/images/themes/theme1/bg.png",
        "profile_background_tile": false,
        "profile_image_url": "http://pbs.twimg.com/profile_images/378800000670976261/6bf68e953e993fd24c7bb5ed702db806_normal.jpeg",
        "profile_image_url_https": "https://pbs.twimg.com/profile_images/378800000670976261/6bf68e953e993fd24c7bb5ed702db806_normal.jpeg",
        "profile_banner_url": "https://pbs.twimg.com/profile_banners/328957205/1353030229",
        "profile_link_color": "0084B4",
        "profile_sidebar_border_color": "C0DEED",
        "profile_sidebar_fill_color": "DDEEF6",
        "profile_text_color": "333333",
        "profile_use_background_image": true,
        "default_profile": true,
        "default_profile_image": false,
        "following": null,
        "follow_request_sent": null,
        "notifications": null
      },
      "geo": null,
      "coordinates": null,
      "place": null,
      "contributors": null,
      "retweeted_status": {
        "metadata": {
          "result_type": "recent",
          "iso_language_code": "en"
        },
        "created_at": "Fri Jan 10 14:24:45 +0000 2014",
        "id": 421648812818833408,
        "id_str": "421648812818833408",
        "text": "Twitter users per capita\n1 Kuwait\n2 N-lands\n3 Brunei\n4 UK\n5 US\n6 Chile\n7 Ireland\nhttp://t.co/j1wQ5fbtkQ\n2010-12 data\nhttp://t.co/pibS8cctta",
        "source": "<a href=\"http://bufferapp.com\" rel=\"nofollow\">Buffer</a>",
        "truncated": false,
        "in_reply_to_status_id": null,
        "in_reply_to_status_id_str": null,
        "in_reply_to_user_id": null,
        "in_reply_to_user_id_str": null,
        "in_reply_to_screen_name": null,
        "user": {
          "id": 71643224,
          "id_str": "71643224",
          "name": "Conrad Hackett",
          "screen_name": "conradhackett",
          "location": "Washington, DC",
          "description": "Demographer, Pew Research Center. Measuring global religion.",
          "url": "http://t.co/5ECkAZwY0U",
          "entities": {
            "url": {
              "urls": [
                {
                  "url": "http://t.co/5ECkAZwY0U",
                  "expanded_url": "http://www.pewresearch.org/experts/conrad-hackett/",
                  "display_url": "pewresearch.org/experts/conrad…",
                  "indices": [
                    0,
                    22
                  ]
                }
              ]
            },
            "description": {
              "urls": [
              ]
            }
          },
          "protected": false,
          "followers_count": 11464,
          "friends_count": 1272,
          "listed_count": 554,
          "created_at": "Fri Sep 04 21:25:12 +0000 2009",
          "favourites_count": 170,
          "utc_offset": -18000,
          "time_zone": "Eastern Time (US & Canada)",
          "geo_enabled": false,
          "verified": false,
          "statuses_count": 1848,
          "lang": "en",
          "contributors_enabled": false,
          "is_translator": false,
          "profile_background_color": "022330",
          "profile_background_image_url": "http://abs.twimg.com/images/themes/theme15/bg.png",
          "profile_background_image_url_https": "https://abs.twimg.com/images/themes/theme15/bg.png",
          "profile_background_tile": false,
          "profile_image_url": "http://pbs.twimg.com/profile_images/2238740539/hackett_sb_2_normal.jpg",
          "profile_image_url_https": "https://pbs.twimg.com/profile_images/2238740539/hackett_sb_2_normal.jpg",
          "profile_banner_url": "https://pbs.twimg.com/profile_banners/71643224/1383450980",
          "profile_link_color": "0084B4",
          "profile_sidebar_border_color": "A8C7F7",
          "profile_sidebar_fill_color": "C0DFEC",
          "profile_text_color": "333333",
          "profile_use_background_image": true,
          "default_profile": false,
          "default_profile_image": false,
          "following": null,
          "follow_request_sent": null,
          "notifications": null
        },
        "geo": null,
        "coordinates": null,
        "place": null,
        "contributors": null,
        "retweet_count": 162,
        "favorite_count": 39,
        "entities": {
          "hashtags": [
          ],
          "symbols": [
          ],
          "urls": [
            {
              "url": "http://t.co/pibS8cctta",
              "expanded_url": "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0061981",
              "display_url": "plosone.org/article/info:d…",
              "indices": [
                117,
                139
              ]
            }
          ],
          "user_mentions": [
          ],
          "media": [
            {
              "id": 421471090570166272,
              "id_str": "421471090570166272",
              "indices": [
                81,
                103
              ],
              "media_url": "http://pbs.twimg.com/media/BdlduUyIAAAocNE.png",
              "media_url_https": "https://pbs.twimg.com/media/BdlduUyIAAAocNE.png",
              "url": "http://t.co/j1wQ5fbtkQ",
              "display_url": "pic.twitter.com/j1wQ5fbtkQ",
              "expanded_url": "http://twitter.com/conradhackett/status/421471090733764608/photo/1",
              "type": "photo",
              "sizes": {
                "large": {
                  "w": 690,
                  "h": 362,
                  "resize": "fit"
                },
                "thumb": {
                  "w": 150,
                  "h": 150,
                  "resize": "crop"
                },
                "small": {
                  "w": 340,
                  "h": 178,
                  "resize": "fit"
                },
                "medium": {
                  "w": 600,
                  "h": 315,
                  "resize": "fit"
                }
              },
              "source_status_id": 421471090733764608,
              "source_status_id_str": "421471090733764608"
            }
          ]
        },
        "favorited": false,
        "retweeted": false,
        "possibly_sensitive": false,
        "lang": "en"
      },
      "retweet_count": 162,
      "favorite_count": 0,
      "entities": {
        "hashtags": [
        ],
        "symbols": [
        ],
        "urls": [
          {
            "url": "http://t.co/pibS8cctta",
            "expanded_url": "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0061981",
            "display_url": "plosone.org/article/info:d…",
            "indices": [
              139,
              140
            ]
          }
        ],
        "user_mentions": [
          {
            "screen_name": "conradhackett",
            "name": "Conrad Hackett",
            "id": 71643224,
            "id_str": "71643224",
            "indices": [
              3,
              17
            ]
          }
        ],
        "media": [
          {
            "id": 421471090570166272,
            "id_str": "421471090570166272",
            "indices": [
              100,
              122
            ],
            "media_url": "http://pbs.twimg.com/media/BdlduUyIAAAocNE.png",
            "media_url_https": "https://pbs.twimg.com/media/BdlduUyIAAAocNE.png",
            "url": "http://t.co/j1wQ5fbtkQ",
            "display_url": "pic.twitter.com/j1wQ5fbtkQ",
            "expanded_url": "http://twitter.com/conradhackett/status/421471090733764608/photo/1",
            "type": "photo",
            "sizes": {
              "large": {
                "w": 690,
                "h": 362,
                "resize": "fit"
              },
              "thumb": {
                "w": 150,
                "h": 150,
                "resize": "crop"
              },
              "small": {
                "w": 340,
                "h": 178,
                "resize": "fit"
              },
              "medium": {
                "w": 600,
                "h": 315,
                "resize": "fit"
              }
            },
            "source_status_id": 421471090733764608,
            "source_status_id_str": "421471090733764608"
          }
        ]
      },
      "favorited": false,
      "retweeted": false,
      "possibly_sensitive": false,
      "lang": "en"
    }
  ],
  "search_metadata": {
    "completed_in": 0.06,
    "max_id": 422133526704979968,
    "max_id_str": "422133526704979968",
    "next_results": "?max_id=422081966914428927&q=10.1371%2Fjournal.pone.0061981&include_entities=1",
    "query": "10.1371%2Fjournal.pone.0061981",
    "refresh_url": "?since_id=422133526704979968&q=10.1371%2Fjournal.pone.0061981&include_entities=1",
    "count": 15,
    "since_id": 0,
    "since_id_str": "0"
  }
}
```

## Source Code
The source code is available [here](https://github.com/articlemetrics/lagotto/blob/master/app/models/sources/twitter_search.rb).

## Further Documentation
* [Twitter Developer Documentation](https://dev.twitter.com/)
* [Twitter Application-Only Authentication](https://dev.twitter.com/docs/auth/application-only-auth)
