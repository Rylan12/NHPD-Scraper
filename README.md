# NHPD-Scraper

Scrape the entries on the "Recent Arrests" page of the [New Haven Police Department's Police To Citizen website](https://newhavenct.policetocitizen.com/RecentArrests/Catalog).

## Data

The data is written to [`data/arrests.csv`](data/arrests.csv).
A link to the raw CSV file can be found [here](https://raw.githubusercontent.com/Rylan12/NHPD-Scraper/main/data/arrests.csv).

## Usage

To fetch the most recent arrests, run the following command which will dump the data into a JSON file in the `data` directory:

```bash
rake fetch
```
