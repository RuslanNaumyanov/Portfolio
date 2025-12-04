create table if not exists jail
(
gangster varchar(100) null,
jailtime_start varchar(10) null, 
jailtime_end varchar(10) null);

# We have a table with gangster's name, the date when a gangster was placed in jail and the date when he was freed.
# We need to show time when there was no one in jail. In given data we have date values as strings, because they aren't in traditional format "%Y-%m-%d",
# so before we insert data in our table, we need to convert strings to dates.

delimiter $$

create trigger feed_dates_into_table
before insert on jail
for each row
begin
	set new.jailtime_start = str_to_date(new.jailtime_start, '%m.%d.%Y');
    set new.jailtime_end = str_to_date(new.jailtime_end, '%m.%d.%Y');
end$$

delimiter ;

insert into jail values ('Иванов', '07.01.1990', '06.30.1991');
insert into jail values ('Петров', '01.01.1993', '12.31.1993');
insert into jail values ('Сидоров', '07.01.1993', '12.31.1994');
insert into jail values ('Зорин', '07.01.1994', '12.31.1995');
insert into jail values ('Зудин', '07.01.1995', '12.31.1996');
insert into jail values ('Зотов', '10.01.1995', '03.31.1996');
insert into jail values ('Звягин', '07.01.1996', '06.30.1997');
insert into jail values ('Гонгадзе', '01.01.1998', '12.31.1998');
insert into jail values ('Волгин', '07.01.1998', '06.30.1999');
insert into jail values ('Онегин', '01.01.1990', '12.31.1991');

# Now we can solve our task. We'll create a temporary table with ordered numbers who first entered and exited jail, so we can reuse this table,
# if we have another tasks with this table.

create temporary table if not exists jail_with_guest_numbers
select *,
row_number() over (order by jailtime_start) num1,
row_number() over (order by jailtime_end) num2
from jail;

# The actual solution is as follows. We replicate our temporary table in CTE and join our CTE with temporary table based on condition that we only need rows when
# next gangster wasn't placed in jail but previous gangster had already left it.

with cte as
(select *,
row_number() over (order by jailtime_start) num1,
row_number() over (order by jailtime_end) num2
from jail)
select cte.jailtime_end free_period_start, j.jailtime_start free_period_end
from jail_with_guest_numbers j
join cte
on j.num1 = cte.num2 + 1
where datediff(j.jailtime_start, cte.jailtime_end) > 0;
