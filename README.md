# NHPD-Scraper

Scrape the entries on the "Recent Arrests" page of the [New Haven Police Department's Police To Citizen website](https://newhavenct.policetocitizen.com/RecentArrests/Catalog).

## Data

The data is written to [`data/arrests.csv`](data/arrests.csv).
A link to the raw CSV file can be found [here](https://raw.githubusercontent.com/Rylan12/NHPD-Scraper/main/data/arrests.csv).

## Usage

First, install the required gems:

```bash
bundle install
```

To update the CSV file, run the following command:

```console
$ bundle exec rake update
Received 574 records from the API.
Updated database with 7 new records and 5 modified records.
```

### Separate Fetch and Dump

To download the latest JSON data from the API, run the following command which will place a JSON file in the `json` directory:

```console
$ bundle exec rake fetch
Received 574 records from the API.
Wrote JSON output to json/20240620T123308.json.
```

To dump the JSON data from the most recent fetch to the CSV file, run the following command:

```console
$ bundle exec rake dump
Read 574 records from json/20240620T123308.json.
Updated database with 7 new records and 5 modified records.
```

## Development

Before submitting changes, run the following command to ensure that the code is formatted correctly:

```console
$ bundle exec rubocop
Inspecting 6 files
......

6 files inspected, no offenses detected
```
