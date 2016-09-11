---
layout: card_list
title: "Notifications"
---

## Setup

To properly set up notifications and reports, do the following:

* make sure at least one filter is enabled
* setup cron jobs for rake tasks with `bin/whenever -w`. Use `bin/whenever` to see all cron jobs created by this command.
* setup report configuration in `.env`. Reports can be sent via mail (using the [Mailgun](https://www.mailgun.com/) service), Slack and/or Webhook. The following ENV variables are used: `ADMIN_EMAIL`, `MAILGUN_API_KEY`, `MAILGUN_DOMAIN`, `SLACK_WEBHOOK_URL`, and `WEBHOOK_URL`.


## Notifications

Notifications are created when errors are raised by the application. The only exception are common errors such as *RecordNotFound*, which are ignored. Notifications that have been resolved can be deleted, and this can be done with a single command for all notifications with the same message, class, or source.

The number of error messages received in the last 24 hours is reported in various places in the admin dashboard.

Since ALM 2.9 we not only collect errors messages, but also other unusual activities, and have therefore renamed error messages to alerts, again renamed to notifications in Lagotto 5.0. Also since ALM 2.9 notifications are also shown next to the works they belong to. This makes it easier to resolve errors.

![Article Alert](/images/alert-article.png)

## Filters

Filters are used to detect unusual actiivty in the data collected from external APIs. These includes errors, suspicious gaming activity, but also highly unusual works. For performance reasons filters are only applied to recently collected data (24 hours by default). The following filters are currently available:

* **ApiResponseTooSlowError**. Raise an error if successful API responses took longer than the specified time in seconds.
* **WorkNotUpdatedError**. Raises an error if works have not been updated within the specified interval in days
* **EventCountDecreasingError**. Raises an error if the event count decreases.
* **EventCountIncreasingTooFastError**. Raises an error if the event count increases faster than the specified value per day.
* **CitationMilestoneAlert**. Creates an alert if an work has been cited the specified number of times.

The last filter detects milestones reached by works, all other filters listed here detect errors with the application. Some filters can be configured, and all filters can be disabled.

![Filters](/images/filters.png)

Filters are relatively easy to write, so please create a Github issue if you have an idea for a new filter. A daily report is then sent out to all admin and staff users who have signed up for this report in their account profile. The report only contains summary information.

## Reports

A background task runs every 24 hours to apply the filters to the API responses of the last 24 hours. Filters can also be applied manually by running `bundle exec rake filter:all`. The API responses will be marked as resolved with this command, use `bundle exec rake filter:unresolve to again mark them as unresolved. Use this command to re-apply filters after changing filter settings.

Reports can be manually sent by using `bundle exec rake notification:all`.
