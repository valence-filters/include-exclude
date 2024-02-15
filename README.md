# Include Exclude

This is a custom extension for <a href="https://valence.app">Valence</a>, a <a href="https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000EORP4UAP">managed package on the Salesforce AppExchange</a> that provides integration middleware natively in a Salesforce org.

To learn more about developing extensions for the Valence platform, have a look at <a href="https://docs.valence.app">the Valence documentation</a>.

## Installing

Click this button to install the Filter into your org.

<a href="https://githubsfdeploy.herokuapp.com?owner=valence-filters&repo=include-exclude&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## What Does This Filter Do?

Allows you to only accept records with certain values and/or exclude records with certain values.

Typically, we prefer to filter at the source Adapter level and not even receive records we're not interested in, but sometimes that's outside our control. This Filter allows for records to be:

1. Discarded if they don't match an inclusion list of values
2. Discarded if they match an exclusion list of values

You can configure this Filter multiple times on the same Link on different mappings.

### Configuring the Filter

![Here's what configuring the Filter looks like](/images/configuring.png)

Be sure to clearly describe why these records are being ignored in your "ignore reason", so that is clear for anyone reviewing Link runs.

### What You See Once Configured

![Each configuration explains what it is going to do](/images/explainer.png)

### Effect on Records

Individual records will be ignored and have the ignore reason attached.

![Here is the impact on the records at runtime](/images/results.png)

All ignore reasons are always rolled up and summarized on the Sync Event Summary screen.

![Combined ignore reasons on the Sync Event Summary screen](/images/syncevent.png)
