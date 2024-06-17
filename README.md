# NHPD-Scraper

Scrape the entries on the "Recent Arrests" page of the [New Haven Police Department's Police To Citizen website](https://newhavenct.policetocitizen.com/RecentArrests/Catalog).

## Data

The data is written to [`data/arrests.csv`](data/arrests.csv).
A link to the raw CSV file can be found [here](https://raw.githubusercontent.com/Rylan12/NHPD-Scraper/main/data/arrests.csv).

## Usage

To update the data, run the following command:

```console
$ rake
Received 568 records from the API.
Wrote JSON output to json/20240616T203021.json.
Read 568 records from json/20240616T203021.json.
Wrote CSV output to data/arrests.csv.
```

> [!NOTE]
> Running this command will overwrite the existing data in `data/arrests.csv`, so any data that is not in the new API response will be lost.
> This means that arrests from more than 1 month ago will be gone (they will still exist in source control, of course).
