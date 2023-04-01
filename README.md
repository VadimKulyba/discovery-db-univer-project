## Title: [discovery-db-univer-project]

### :bulb: Motivation and Tech stack

> The project was created while studying at the university to take an advanced course in databases.
The project is inspired by the travels and expeditions of the discovery channel.
Project used Oracle-specific SQL syntax.

### :key: Features
- Init database scripts
- List of most useful queries
- Procedures
- Triggers
- Views
- etc

### :page_with_curl: Schema description

This is a database schema for a travel company that organizes trips to various regions around the world, and produces television shows about the trips. The schema includes three tables: Travelers, Regions, and Teleshows.

The Travelers table includes information about travelers who participate in the trips organized by the travel company. The table has columns for TravelerNumber (a unique identifier for each traveler), TravelerEmail, FirstName, LastName, Department, TravelerRole, PhoneNumber. The TravelerRole column has a default value of 'traveler' and a CHECK constraint that allows the values 'admin', 'traveler', and 'worker'.

The Regions table includes information about regions where the travel company organizes trips. The table has columns for NumberRegion (a unique identifier for each region), RegionName, SpaceType, DangerLevel, and RegionDescription. The DangerLevel column has a CHECK constraint that allows values between 1 and 10. The table also includes a primary key constraint on the NumberRegion column.

The Teleshows table includes information about television shows produced by the travel company. The table has columns for NumberTeleshow (a unique identifier for each show), Chanel, and TeleshowName. The table also includes a primary key constraint on the NumberTeleshow column.

Sequences have been defined for generating unique identifiers for the Travelers, Regions, and Teleshows tables. These sequences start with 1 and increment by 1 for each new record.
