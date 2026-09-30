# 🗄️ LAPD Crime Data: Storage Pipeline & SQL vs NoSQL Benchmark

A data storage and processing project on over 1 million records of Los Angeles crime data. The raw CSV is stored in Hadoop HDFS and processed with a Python MapReduce job, loaded into both MySQL and MongoDB for analysis, and the two databases are benchmarked against each other with YCSB. Built individually for the **Data Storage Solutions** module (Year 3, CCT College Dublin).

## What it does

- **Distributed storage:** uploads the raw CSV to HDFS (`/user1/crime/Crime_Data.csv`) on an Ubuntu VM
- **MapReduce:** a Hadoop Streaming job with a Python [mapper](mapper.py) and [reducer](reducer.py) that counts crimes per LAPD area
- **SQL analysis:** [mysql.sql](mysql.sql) creates the `crimedb.crimes` table, bulk-loads the CSV and runs three queries (`WHERE`, `GROUP BY`, `ORDER BY`)
- **NoSQL analysis:** [MongoDB.js](MongoDB.js) runs the same three analyses as aggregation pipelines (`$match`, `$group`, `$sort`)
- **Benchmarking:** YCSB v0.17.0 comparing MySQL and MongoDB on three standard workloads, with the raw output in [`benchmarks/`](benchmarks/)

## Architecture

```
data.gov CSV ──► Ubuntu VM (local storage) ──► Hadoop HDFS ──► MapReduce (Python): crimes per area
                                  │
                                  ├──► MySQL   (crimedb.crimes, rows)      ──► SQL queries   ─┐
                                  └──► MongoDB (crimedb.crimes, documents) ──► aggregations  ─┴─► YCSB benchmark
```

## Tech

Hadoop (HDFS, Hadoop Streaming) · Python 3 · MySQL · MongoDB · YCSB 0.17.0 · Ubuntu Linux

## Findings

**From the queries and MapReduce job:**
- Streets were the most common location for crimes
- Vehicle theft was the most common crime type
- 2024 had fewer recorded crimes than the previous years
- 77th Street was the LAPD area with the most crimes

**From the YCSB benchmark** (20,000 records loaded, 1,000 operations per run):

| Workload | Metric | MySQL | MongoDB |
|---|---|---:|---:|
| **A**: 50% read / 50% update | Throughput (ops/sec) | 397 | **2,151** |
| | Runtime (ms) | 2,521 | **465** |
| | Read avg latency (µs) | 476 | **202** |
| | Update avg latency (µs) | 4,042 | **280** |
| **B**: 95% read / 5% update | Throughput (ops/sec) | 1,215 | **1,669** |
| | Runtime (ms) | 823 | **599** |
| **C**: 100% read | Throughput (ops/sec) | **1,996** | 1,783 |
| | Runtime (ms) | **501** | 561 |

MongoDB was much faster on the update-heavy workload, while MySQL was slightly ahead on read-only access. The right choice depends on the workload: MongoDB for write-intensive or flexible-schema data, MySQL for structured, read-heavy analytical queries. This matches the findings of Pandey (2020).

## How to run

**You need:** Hadoop (with HDFS running), Python 3, MySQL, MongoDB and YCSB 0.17.0, on Linux.

1. Download the dataset: [Crime Data from 2020 to Present](https://catalog.data.gov/dataset/crime-data-from-2020-to-present) (data.gov) and save it as `Crime_Data.csv`. It isn't included here because of its size.
2. **HDFS + MapReduce:**
   ```bash
   hdfs dfs -mkdir -p /user1/crime
   hdfs dfs -put Crime_Data.csv /user1/crime/
   hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
     -files mapper.py,reducer.py -mapper mapper.py -reducer reducer.py \
     -input /user1/crime/Crime_Data.csv -output /user1/crime/output
   hdfs dfs -cat /user1/crime/output/part-00000
   ```
3. **MySQL:** update the CSV path in `mysql.sql`, then run it in the MySQL client (`LOAD DATA LOCAL INFILE` requires `local_infile` to be enabled).
4. **MongoDB:** import the CSV into `crimedb.crimes` (e.g. `mongoimport --db crimedb --collection crimes --type csv --headerline --file Crime_Data.csv`), then run the queries in `MongoDB.js` in `mongosh`.
5. **YCSB:** load and run each workload with `-p recordcount=20000`, using the `jdbc` binding for MySQL and the `mongodb` binding for MongoDB.

## Notes and known limitations

- Each benchmark was a single run of 1,000 operations on a local VM, so the results are indicative rather than statistically robust.
- All MySQL columns are stored as `VARCHAR`, so dates are parsed with `SUBSTRING` rather than stored as date types.
- The mapper splits lines on commas; this works for the area name column, but a CSV parser would be safer for fields that contain quoted commas.

## Credits

- Dataset: Los Angeles Police Department, [Crime Data from 2020 to Present](https://catalog.data.gov/dataset/crime-data-from-2020-to-present), via data.gov
- MapReduce approach adapted from Ancavil, R. (2020), *MapReduce Example with Python*
- Pandey, R. (2020), *Performance Benchmarking and Comparison of Cloud-Based Databases MongoDB (NoSQL) Vs MySQL (Relational) using YCSB*
