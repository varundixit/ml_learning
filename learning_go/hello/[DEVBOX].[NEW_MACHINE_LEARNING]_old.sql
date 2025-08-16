CREATE PROC [DEVBOX].[NEW_MACHINE_LEARNING] @from_date [date],@to_date [date] AS

BEGIN


declare @from_date_id int = convert(varchar(8),@from_date,112)
declare @to_date_id int = convert(varchar(8),@to_date,112)



------customers
----if object_id('tempdb..##temp') is not null drop table #temp

if object_id('tempdb..#customers') is not null drop table #customers


SELECT wh_player_id
,src_player_id
,user_name
, signup_date as signup_datetime
, cast(signup_date as date) signup_date
, DATEADD(DAY, 6, c.signup_date) signup_date_6
, DATEADD(DAY, 7, c.signup_date) signup_date_7
, DATEADD(DAY, 36, c.signup_date) signup_date_36
, DATEADD(DAY, 96, c.signup_date) signup_date_96
, convert(varchar(8),c.signup_date,112) signup_date_id
, convert(varchar(8),DATEADD(DAY, 6, c.signup_date),112) signup_date_id_6
, convert(varchar(8),DATEADD(DAY, 7, c.signup_date),112) signup_date_id_7
, convert(varchar(8),DATEADD(DAY, 36, c.signup_date),112) signup_date_id_36
, convert(varchar(8),DATEADD(DAY, 96, c.signup_date),112) signup_date_id_96
, date_of_birth
,year(signup_Date)-year(date_of_birth) as age
,gender
, advertiser_name
, acquisition_channel
, acquisition_tag
,first_deposit_date ---sms_yn, email_yn
into #customers
FROM PROD_VIEWS.Dim_Player_pl c
WHERE wh_src_Country_cd = 'PL' AND signup_Date between @from_date AND @to_date
AND internal_player_yn = 'N';

print(1)

--select logins, login_days 
--from [DevBox].[TH87_loyal_temp_opt]
--group by logins, login_days 
--order by logins, login_days ;

--gi '[PL_DER].[Player_Login_Sessions]'

----------logins
if object_id('tempdb..#logins') is not null drop table #logins

SELECT  c.wh_player_id
,COUNT(1) AS logins
,COUNT(distinct CAST(ls.session_start_time AS DATE)) AS login_days
into #logins
FROM #customers c
JOIN [PL_DER].[Player_Login_Sessions] ls ON c.wh_player_id = ls.wh_player_id
where CAST(ls.session_start_time AS DATE) BETWEEN c.signup_date AND c.signup_date_6
GROUP BY c.wh_player_id;
print(2)

----------------------------#depositsandwithdrawals
IF OBJECT_ID('tempdb..#depositsandwithdrawals') IS NOT NULL DROP TABLE #depositsandwithdrawals;

select a.wh_player_id,a.signup_datetime,a.first_deposit_date,
datediff(minute, a.signup_datetime, a.first_deposit_date) as signup_to_deposit_time_mins,
max(case when dep_rank = 2 and timex < 7 then txn_accepted_datetime end) as second_deposit_date,
max(case when dep_rank = 3 and timex < 7 then txn_accepted_datetime end) as third_deposit_date,
isnull(sum(case when txn_type_desc = 'deposit' and txn_status_desc = 'approved' and timex between 0 and 6 then 1 end), 0) as deposit_count,
isnull(sum(case when txn_type_desc = 'deposit' and txn_status_desc = 'approved' and timex < 7 then txn_amt_tc end), 0) as deposit_amount,
isnull(sum(case when txn_type_desc = 'withdraw' and txn_status_desc ='approved' and timex between 0 and 6 then 1 end), 0) as withdraw_count,
isnull(sum(case when txn_type_desc = 'withdraw' and txn_status_desc = 'approved' and timex between 0 and 6 then txn_amt_tc end), 0) as withdraw_amount,
---------
isnull(sum(case when txn_type_desc = 'deposit' and txn_status_desc = 'approved' and timex >=7 then 1 end), 0) as recon_deposit_count,
isnull(sum(case when txn_type_desc = 'deposit' and txn_status_desc = 'approved' and timex > 7 then txn_amt_tc end), 0) as recon_deposit_amount,
isnull(sum(case when txn_type_desc = 'withdraw' and txn_status_desc ='approved' and timex >=7 then 1 end), 0) as recon_withdraw_count,
isnull(sum(case when txn_type_desc = 'withdraw' and txn_status_desc = 'approved' and timex > 7 then txn_amt_tc end), 0) as recon_withdraw_amount

into #depositsandwithdrawals
from (
select 
c.wh_player_id,
c.signup_datetime,
c.signup_date,
c.first_deposit_date,
b.txn_type_desc,
b.txn_status_desc,
b.txn_amt_tc,
b.txn_accepted_datetime
, row_number() over (partition by c.wh_player_id, b.txn_type_desc order by b.txn_accepted_datetime) as dep_rank
, datediff(day, c.signup_date, cast(b.txn_accepted_datetime as date)) as timex
from #customers c
inner join [pl_der].[f_cashier_txn] b on c.wh_player_id = b.wh_player_id
where b.txn_type_desc IN ('deposit', 'withdraw') and b.txn_status_desc = 'approved'
) a
group by a.wh_player_id,a.signup_date,a.signup_datetime,a.first_deposit_date

------balance
if object_id('tempdb..#balance') is not null drop table #balance
select c.wh_player_id,bl.balance
into #balance
from (
select wh_player_id,signup_date_6 as thresh from #customers) c
left join [reporting].[fd_player_account_balance] bl on c.wh_player_id = bl.wh_player_id and c.thresh = bl.summary_date

print(3)

------------ f_slips_and_sports_data
if object_id('tempdb..#fslips_and_sports_data') is not null drop table #fslips_and_sports_data

select c.wh_player_id,
c.src_player_id,
c.user_name,
c.signup_date,
c.signup_date_6,
c.signup_date_7,
c.signup_date_36,
c.signup_date_96,
c.date_of_birth,
c.gender,
c.advertiser_name,
c.acquisition_channel,
c.acquisition_tag,
c.first_deposit_date,
z.wh_slip_id,
z.Src_Ticket_CD,
z.placed_datetime,
z.wh_placed_date_id,
z.src_slip_status_id,
z.wh_slip_status_id,
z.pay_in_amt_tc,
z.win_amt_tc,
z.wh_placed_cash_register_id,
z.wh_product_type_id as slip_product_type_id,
h.wh_product_type_id as hierarchy_product_type_id,
h.wh_product_desc,
h.wh_product_group_desc
into #fslips_and_sports_data
from #customers c
left join [PROD_VIEWS].[f_Slips_snapshot] z on c.wh_player_id = z.wh_player_id
left join [PROD_VIEWS].[DIM_PRODUCT_TYPE_HIERARCHY] h on z.wh_product_type_id = h.wh_product_type_id
where src_slip_status_id in ('1','4','7')  
and Wh_Placed_Date_ID between signup_date_id and signup_date_id_96
and z.pay_in_amt_tc > 0
--and cast(placed_datetime as date) between  @from_Date and @to_date 
--and datediff(day,c.signup_date,z.placed_datetime) between 0 and 96


print(4)

--gi '[PROD_VIEWS].[f_Slips_snapshot]'

if object_id('tempdb..#ivg_fog') is not null drop table #ivg_fog
select a.wh_player_id,
sum(case when a.wh_product_group_desc = 'IVG'        then 1 else 0 end) as ivg_count,
sum(case when a.wh_product_group_desc = 'IVG'        then a.pay_in_amt_tc else 0 end) as ivg_stake,
sum(case when a.wh_product_group_desc = 'Numericals' then 1 else 0 end) as fog_count,
sum(case when a.wh_product_group_desc = 'Numericals' then a.pay_in_amt_tc else 0 end) as fog_stake
into #ivg_fog
from #fslips_and_sports_data a
WHERE a.wh_product_group_Desc in ('IVG', 'Numericals')
and a.placed_datetime between a.signup_date and a.signup_date_6
group by a.wh_player_id

print(6)

------------prod_type_heirarachy_sportsbook

if object_id('tempdb..#fslips_sports_book ') is not null drop table #fslips_sports_book 
select * 
into #fslips_sports_book 
from #fslips_and_sports_data a
where a.wh_product_group_desc = 'sportsbook'

print(7)
--------------timex
if object_id('tempdb..#timex') is not null drop table #timex

select sub.wh_player_id,
max(case when rn =1 then sub.placed_datetime end) as first_bet_date,
max(case when  rn = 1 then datename(weekday,sub.placed_datetime) end) as first_bet_weekday,
count(case when weekdayx in ('monday','tuesday','wednesday','thursday','friday') then 1 end) as work_week_betslips,
count(case when weekdayx in ('saturday','sunday') then 1 end) as weekend_betslips,
count(*) as betslips,
sum(case when weekdayx in ('monday','tuesday','wednesday','thursday','friday') then sub.pay_in_amt_tc else 0 end) as work_week_stake,
sum(case when weekdayx in ('saturday','sunday') then sub.pay_in_amt_tc else 0 end) as weekend_stake,
sum(sub.pay_in_amt_tc) as stake,
sum(sub.win_amt_tc) as win,
count(distinct cast (sub.placed_datetime as date)) as apds,
sum(case when weekdayx in ('monday','tuesday','wednesday','thursday','friday') and hour between 0 and 5 then 1 else 0 end ) as work_week_0_5_betslips,
sum(case when weekdayx in ('monday','tuesday','wednesday','thursday','friday') and hour between 6 and 11 then 1 else 0 end ) as work_week_6_11_betslips,
sum(case when weekdayx in ('monday','tuesday','wednesday','thursday','friday') and hour between 12 and 17 then 1 else 0 end ) as work_week_12_17_betslips,
sum(case when weekdayx in ('monday','tuesday','wednesday','thursday','friday') and hour between 18 and 23 then 1 else 0 end ) as work_week_18_23_betslips,
sum(case when weekdayx in ('saturday','sunday') and hour between 0 and 5 then 1 else 0 end ) as weekend_0_5_betslips,
sum(case when weekdayx in ('saturday','sunday') and hour between 6 and 11 then 1 else 0 end ) as weekend_6_11_betslips,
sum(case when weekdayx in ('saturday','sunday') and hour between 12 and 17 then 1 else 0 end ) as weekend_12_17_betslips,
sum(case when weekdayx in ('saturday','sunday') and hour between 18 and 23 then 1 else 0 end ) as weekend_18_23_betslips
into #timex
from (
select  a.wh_player_id,a.placed_datetime,a.pay_in_amt_tc,a.win_amt_tc,
DATENAME(weekday, a.placed_datetime) AS weekdayx,
DATEPART(hour, a.placed_datetime) AS hour,
ROW_NUMBER() OVER (PARTITION BY a.wh_player_id ORDER BY a.placed_datetime) AS rn
from #fslips_sports_book a
where a.placed_datetime between signup_date and signup_date_6
) sub
group by wh_player_id
print(8)

--gi 'PROD_VIEWS.F_Bets_Snapshot_PL'

------------NBS_SBK_PL.F_SLIP_LEG_BRIDGE a
--select * 
--from NBS_SBK_PL.F_SLIP_LEG_BRIDGE a
--left join NBS_SBK_PL.F_SLIP_DETAILS b on a.src_ticket_cd = b.src_ticket_cd
--left join NBS_SBK_PL.DIM_SPORT s on s.dl_sport_id=a.dl_sport_id

--------f_bets
if object_id('tempdb..#sport_fbets') is not null drop table #sport_fbets
select b.*,a.dl_sport_id
into #sport_fbets
from NBS_SBK_PL.F_SLIP_LEG_BRIDGE a 
join #fslips_sports_book b on a.src_ticket_cd = b.src_ticket_cd 
--join #customers c on a.Wh_Player_Id = c.Wh_Player_Id
--where Wh_Placed_Date_ID >= @from_date_id and Wh_Placed_Date_ID < @to_date_id and src_Slip_status_id in ('1','4','7') 

print(9)

---so 'u.nbs_sbk_pl.'

---NBS_SBK_PL.F_SLIP_DETAILS
---NBS_SBK_PL.DIM_TERMINAL_DETAILS

--select distinct betslip_state from NBS_SBK_PL.F_SLIP_DETAILS
---select distinct  betslip_product from NBS_SBK_PL.F_SLIP_LEG_BRIDGE 
----------ivg and fog
------------------

if object_id('tempdb..#sport_agg') IS NOT NULL drop table #sport_agg; select  a.wh_player_id, s.Sport_name_english as src_sport_desc, s.sport_id as src_sport_id, a.wh_product_desc, count(*) as countx into #sport_agg  from #sport_fbets a   left join NBS_SBK_PL.DIM_SPORT s on s.dl_sport_id=a.dl_sport_id --where datediff(day, a.signup_date, a.placed_datetime) between 0 and 6 where a.placed_datetime between signup_date and signup_date_6 group by  a.wh_player_id,  s.Sport_name_english,  s.sport_id,  a.wh_product_desc;  if object_id('tempdb..#sport') IS NOT NULL drop table #sport; select x.wh_player_id, x.src_sport_desc, x.src_sport_id , x.wh_product_desc , countx  into #sport from( select *, row_number() over (partition by wh_player_id order by countx desc) as rk from #sport_agg  ) x where rk = 1

print(10)
------------ platform
if object_id('tempdb..#platformx') is not null drop table #platformx
select x.wh_player_id,
max(case when rn = 1 then x.client_platform_type end) as favourite_platform,
sum(case when x.client_platform_type = 'Internet - Desktop' then betslips else 0 end) as desktop_betslips,
sum(case when x.client_platform_type = 'Mobile - Android OS' then betslips else 0 end) as android_betslips,
sum(case when x.client_platform_type = 'Mobile - Generic' then betslips else 0 end) as gm_betslips,
sum(case when x.client_platform_type = 'Mobile - iOS' then betslips else 0 end) as ios_betslips,
sum(case when x.client_platform_type = 'Retail - Manned Counters' then betslips else 0 end) as retail_betslips,
count(distinct x.client_platform_type) as unique_platforms

into #platformx
from (
select a.wh_player_id,cc.client_platform_type,count(*) as betslips,row_number() over (partition by a.wh_player_id order by count(*) desc) as rn
from #fslips_sports_book a
left join [PROD_VIEWS].[Dim_slip_status] s on a.wh_slip_status_id = s.wh_slip_status_id
left join [PROD_VIEWS].[Dim_Cash_register] cc on a.[wh_placed_cash_register_id] = cc.wh_cash_register_id
where a.placed_datetime between signup_date and signup_date_6
group by a.wh_player_id,cc.client_platform_type
) x
group by x.wh_player_id
print(11)
-------------inspired bets
if object_id('tempdb..#inspired') is not null drop table #inspired
select c.wh_player_id
,count(distinct case when b.placed_datetime between  signup_date and signup_date_6 then b.src_ticket_cd end) as inspired_betslips
into #inspired
from #customers c
inner join ticketarena_presentation.F_Shared_Betslip_Details_pl b on c.wh_player_id = b.wh_player_id
group by c.wh_player_id
print(12)
------------------- shared bets
if object_id('tempdb..#shared') is not null drop table #shared
select c.wh_player_id,count(case when b.shared_datetime between signup_date and signup_date_6 then 1 end) as shared_ta

into #shared
from #customers c
inner join ticketarena_presentation.F_Shared_Betslip_Details_pl b on c.wh_player_id = b.wh_player_id
group by c.wh_player_id
print(13)
---------------------
if object_id('tempdb..#contacts') is not null drop table #contacts
select c.wh_player_id,
max(case when tagName = 'legal/marketingInformationByEmail' then  cast(t.eventdate as date) end) as email_Date,
max(case when tagName = 'legal/marketingInformationByEmail' then t.newvalue end) as email_consent14,
max(case when tagName = 'legal/marketingInformationByPhone' then cast(t.eventdate as date) end) as phone_Date,
max(case when tagName = 'legal/marketingInformationByPhone' then t.newvalue end) as phone_consent14
into #contacts
from #customers c
left join [PROD_VIEWS].[Dim_Player_Contact_Preferences_Snapshot] ps on c.wh_player_id =ps.wh_player_id
left join [PL_IMS].[PLAYERS_TAGS_CHANGES] t on c.src_player_id = t.playercode
where t.tagname in ('legal/marketingInformationByEmail','legal/marketingInformationByPhone') 
--and eventdate between signup_date and signup_date_6
group by c.wh_player_id
print(15)

------------------new
--if object_id('tempdb..#tag_events') IS NOT NULL drop table #tag_events

--select c.wh_player_id,t.tagname,cast(t.eventdate As date) as event_date,t.newvalue,
--row_number() over (partition by c.wh_player_id,t.tagname ORDER BY t.eventdate) as rn
--INTO #tag_events
--FROM #customers c
--left join [PROD_VIEWS].[Dim_Player_Contact_Preferences_Snapshot] ps on c.wh_player_id =ps.wh_player_id
--LEFT JOIN [PL_IMS].[PLAYERS_TAGS_CHANGES] t on c.src_player_id = t.playercode
--where t.tagname IN ('legal/marketingInformationByEmail', 'legal/marketingInformationByPhone')
----and t.eventdate between c.signup_date and c.signup_date_6
 
-- print(16)
-------------------
--if object_id ('tempdb..#first_tag_event') IS NOT NULL drop table  #first_tag_event
--select *
--into #first_tag_event
--from #tag_events
--where rn = 1

---------------------
--if object_id('tempdb..#contacts') IS NOT NULL drop table #contacts
--select wh_player_id,
--MAX(case when tagname = 'legal/marketingInformationByEmail' then event_date end) as email_date,
--MAX(case when tagname = 'legal/marketingInformationByEmail' then newvalue end) as email_consent14,
--MAX(case when tagname = 'legal/marketingInformationByPhone' then event_date end) as phone_date,
--MAX(case when tagname = 'legal/marketingInformationByPhone' then newvalue end) as phone_consent14
--into #contacts
--from #first_tag_event
--group by wh_player_id

print(17)

-----------result
if object_id('tempdb..#result') is not null drop table #result
select a.wh_player_id,
count(distinct case when a.placed_datetime between  signup_date_7 and signup_date_36 then cast(a.placed_Datetime as date) end) as apds_30,
sum(case when a.placed_Datetime between    signup_date_7 and signup_date_36 then a.pay_in_amt_tc end) as stake_30,
count(distinct case when a.placed_datetime between  signup_date_7 and signup_date_96 then cast(a.placed_Datetime as date) end) as apds_90,
sum(case when a.placed_datetime between    signup_date_7 and signup_date_96 then a.pay_in_amt_tc end) as stake_90,
max(a.placed_Datetime) as last_bet

into #result
from #fslips_sports_book a
where a.pay_in_amt_tc > 0
group by a.wh_player_id
print(16)


------------------
IF OBJECT_ID('tempdb..#final_output') IS NOT NULL DROP TABLE #final_output;

SELECT 
c.wh_player_id,
c.src_player_id,
c.user_name, 
c.signup_date, 
c.signup_datetime,
c.age,gender, 
c.advertiser_name, 
c.acquisition_channel, 
c.acquisition_tag,
isnull(ls.logins, 0) as logins,
isnull(ls.login_days, 0) as login_days,
dw.first_deposit_date,
dw.signup_to_deposit_time_mins,
dw.second_deposit_date,
dw.third_deposit_date,
isnull(dw.deposit_count, 0) as deposit_count,
isnull(dw.deposit_amount, 0) as deposit_amount,
isnull(dw.withdraw_count, 0) as withdraw_count,
isnull(dw.withdraw_amount, 0) as withdraw_amount,
----
isnull(dw.recon_deposit_count, 0) as recon_deposit_count,
isnull(dw.recon_deposit_amount, 0) as recon_deposit_amount,
isnull(dw.recon_withdraw_count, 0) as recon_withdraw_count,
isnull(dw.recon_withdraw_amount, 0) as recon_withdraw_amount,
-----
isnull(bal.balance, 0) as balance,
isnull(ivf.ivg_count, 0) as ivg_count,
isnull(ivf.ivg_stake, 0) as ivg_stake,
isnull(ivf.fog_count, 0) as fog_count,
isnull(ivf.fog_stake, 0) as fog_stake,
tx.first_bet_date,
tx.first_bet_weekday,
isnull(tx.work_week_betslips, 0) as work_week_betslips,
isnull(tx.weekend_betslips, 0) as weekend_betslips,
isnull(tx.betslips, 0) as betslips,
isnull(tx.work_week_stake, 0) as work_week_stake,
isnull(tx.weekend_stake, 0) as weekend_stake,
isnull(tx.stake, 0) as stake,
isnull(tx.win, 0) as win,
isnull(tx.apds, 0) as apds,
isnull(tx.work_week_0_5_betslips, 0) as work_week_0_5_betslips,
isnull(tx.work_week_6_11_betslips, 0) as work_week_6_11_betslips,
isnull(tx.work_week_12_17_betslips, 0) as work_week_12_17_betslips,
isnull(tx.work_week_18_23_betslips, 0) as work_week_18_23_betslips,
isnull(tx.weekend_0_5_betslips, 0) as weekend_0_5_betslips,
isnull(tx.weekend_6_11_betslips, 0) as weekend_6_11_betslips,
isnull(tx.weekend_12_17_betslips, 0) as weekend_12_17_betslips,
isnull(tx.weekend_18_23_betslips, 0) as weekend_18_23_betslips,
s.src_sport_desc as favourite_sport,
s.src_sport_id as favourite_sport_id,
s.wh_product_desc as favourite_sport_product,
isnull(s.countx, 0) as favourite_sport_bets,
case when c.signup_date < '2022-01-01' then 999999 else isnull(sh.shared_ta, 0) end as shared_ta,
case when c.signup_date < '2022-01-01' then 999999 else isnull(ins.inspired_betslips, 0) end as inspired_betslips,
sm.email_date,
coalesce(sm.email_consent14, 'NA') as mail_consent14,
sm.phone_date,
coalesce(sm.phone_consent14, 'NA') as phone_consent14,
p.favourite_platform,
isnull(p.desktop_betslips, 0) as desktop_betslips,
isnull(p.android_betslips, 0) as android_betslips,
isnull(p.gm_betslips, 0) as gm_betslips,
isnull(p.ios_betslips, 0) as ios_betslips,
isnull(p.retail_betslips, 0) as retail_betslips,
isnull(p.unique_platforms, 0) as unique_platforms,
isnull(r.apds_30, 0) as apds_30,
isnull(r.stake_30, 0) as stake_30,
isnull(r.apds_90, 0) as apds_90,
isnull(r.stake_90, 0) as stake_90,
r.last_bet
into #final_output
from #customers c
LEFT JOIN #logins ls on c.wh_player_id = ls.wh_player_id
left join #depositsandwithdrawals dw on c.wh_player_id = dw.wh_player_id
LEFT JOIN #balance bal ON c.wh_player_id = bal.wh_player_id
LEFT JOIN #ivg_fog ivf ON c.wh_player_id = ivf.wh_player_id
LEFT JOIN #timex tx ON c.wh_player_id = tx.wh_player_id
LEFT JOIN #sport s ON c.wh_player_id = s.wh_player_id
LEFT JOIN #shared sh ON c.wh_player_id = sh.wh_player_id
LEFT JOIN #inspired ins ON c.wh_player_id = ins.wh_player_id
LEFT JOIN #contacts sm ON c.wh_player_id = sm.wh_player_id
LEFT JOIN #platformx p ON c.wh_player_id = p.wh_player_id
LEFT JOIN #result r ON c.wh_player_id = r.wh_player_id

print(16)

-----------------

if object_id('[DevBox].[new_mach_mod]') IS NULL
BEGIN
select top 0 *
into [DevBox].[new_mach_mod]
from #final_output
END

----------------------
delete from [DevBox].[new_mach_mod]
where wh_player_id IN (select wh_player_id from #final_output)
--------------
insert into [DevBox].[new_mach_mod]
select * from #final_output 

END 

