CREATE TABLE "Country" (
  "country_id" INTEGER,
  "country_iso3c" CHAR(3),
  "country_name" VARCHAR(100),
  "region" VARCHAR(100),
  "income_group" VARCHAR(100),
  PRIMARY KEY ("country_id")
);

CREATE TABLE "JointStatement" (
  "doc_id" SERIAL PRIMARY KEY,
  "country1_id" INTEGER,
  "country2_id" INTEGER CHECK ("country2_id" <> "country1_id"),
  "release_date" date,
  "title" VARCHAR(100),
  "location" VARCHAR(100),
  "fulltext" TEXT,
  "source" VARCHAR(250),
  "confidence_level1" BOOLEAN,
  "confidence_level2" BOOLEAN,
  CONSTRAINT "FK_Joint_Statement_country1_id"
    FOREIGN KEY ("country1_id")
      REFERENCES "Country"("country_id"),
  CONSTRAINT "FK_Joint_Statement_country2_id"
    FOREIGN KEY ("country2_id")
      REFERENCES "Country"("country_id")
);

create or replace view "TreatyLevel" as 
select "JointStatement".country1_id,  "JointStatement".country2_id, "JointStatement".release_date, 
"JointStatement".confidence_level1, "JointStatement".confidence_level2 from "JointStatement" join
(
	select
	distinct
		case when country1_id < country2_id then
		country1_id else country2_id end c1,
		case when country1_id > country2_id then
		country1_id else country2_id end c2,
		release_date cd,
		min("JointStatement".doc_id) doc_id
from "JointStatement"
group by c1, c2, cd
) ukeys
using (doc_id)
ORDER BY country1_id, country2_id, release_date
;