/**  MongoDB.js
MongoDB queries for crime data analysis
Author: Barbara
Dataset: Crime Data from Los Angeles Police Department
Description: 3 MongoDB aggregation queries equivalent to MySQL queries
*/

// Total crimes per year
db.crimes.aggregate([
  { $match: { "DATE OCC": { $ne: "" } } },
  { $group: {
      _id: { $substr: ["$DATE OCC", 6, 4] },
      Total_Crimes: { $sum: 1 }
  }},
  { $sort: { _id: 1 } }
])

// Top 10 crime locations
db.crimes.aggregate([
  { $match: { "Premis Desc": { $ne: "" } } },
  { $group: { _id: "$Premis Desc", Total_Crimes: { $sum: 1 } } },
  { $sort: { Total_Crimes: -1 } },
  { $limit: 10 }
])

// Top 10 crime types
db.crimes.aggregate([
  { $match: { "Crm Cd Desc": { $ne: "" } } },
  { $group: { _id: "$Crm Cd Desc", Occurrences: { $sum: 1 } } },
  { $sort: { Occurrences: -1 } },
  { $limit: 10 }
])

