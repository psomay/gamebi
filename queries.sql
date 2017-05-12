/* 1.Write a query in mysql to rank the coaches for each year by number of wins. Should be a query (not a stored procedure)*/
set @pk1 ='';
set @rn1 =1;
set @w ='';
SELECT  coachID,
        w, yr,
        rank
FROM
(
  SELECT  coachID,
          w,yr,
          @rn1 := if(@pk1=coachID, if(@w=w, @rn1, @rn1+1),1) as rank,
          @pk1 := coachID,
          @w := w          
  FROM
  (
    SELECT  c.coachID,
            c.w,c.year as yr
    FROM    test_db.coaches c    
    ORDER BY coachID,w,yr
) A
) B;

/* 2.Write a stored procedure in mysql to rank the player for each year for number of awards using cursor*/
/* Table DDL for storing the result set of the Stored PROCEDURE */
CREATE TABLE test_db.rankplayers 
(
playid varchar(30),
 pawards int(4), 
 pyear varchar(10),
 prank int(4)
 );


CREATE DEFINER=`root`@`localhost` PROCEDURE `Rank_player`()
BEGIN
DECLARE cur_yr varchar(10);
DECLARE cur_award int(4);
DECLARE pk1 varchar(10);
DECLARE rn1 int(4);
DECLARE a varchar(10);

DECLARE cur1 CURSOR FOR select distinct year from test_db.awardsplayers;
SET @pk1 ='';
SET @rn1 =1;
SET @a =0; 

OPEN cur1;
        curLoop: loop
            FETCH cur1 INTO cur_yr;
				INSERT INTO test_db.rankplayers
				SELECT  playerID, awards, yr, rank
				FROM
				(
					SELECT  playerID,
							awards,yr,
							@rn1 := if(@pk1=yr, if(@a=awards, @rn1, @rn1+1),1) as rank,
							@pk1 := yr,
							@a := awards						
					FROM
						(
							select playerID,year as yr,count(award) as awards from test_db.awardsplayers 
                            where year=cur_yr
						group by playerID,year
						order by year, count(award) desc
						) A
				) B 
				;
                
		END loop curLoop;		
CLOSE cur1;
END

/* Write a query to get the details of a player who won the maximum number of awards for a year during which the coach for that team also has the maximum wins*/

select p.playerID,p.year, m.coachID,count(award),max(c.w), c.tmID from test_db.master m
left join test_db.awardsplayers p
on m.playerID=p.playerID and m.coachID IS NOT NULL
left join test_db.coaches c
on m.coachID=c.coachID 
where p.playerID IS NOT NULL and m.coachID <>'' and c.w IS NOT NULL
group by p.playerID,p.year, m.coachID, c.tmID
order by p.year ,c.w desc, count(award) desc

/*----- WIth Team */

select p.playerID,p.year, m.coachID,count(award),max(c.w) from test_db.master m
left join test_db.awardsplayers p
on m.playerID=p.playerID and m.coachID IS NOT NULL
left join test_db.coaches c
on m.coachID=c.coachID 
where p.playerID IS NOT NULL and m.coachID <>'' and c.w IS NOT NULL
group by p.playerID,p.year, m.coachID
order by p.year ,c.w desc, count(award) desc
