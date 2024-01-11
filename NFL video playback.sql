with one as (
      select 
FORMAT_DATE('%A', mt.day_dt) AS day,
DATE_TRUNC(mt.day_dt, WEEK) AS WEEK,
mt.visit_session_id as visit_session,
mt.	device_platform_nm as platform,
pd.cd_path_detail_desc as short_path,
last_touch_feature_desc as last_touch_short_path,
mt.reporting_series_nm as multiseries,
mt.video_series_nm as multivideo_series,
pd.video_nm as path_videonm,
cd_full_path_detail_desc as long_path,
last_touch_feature_detail_desc as  last_touch_long_path,
video_playback_ind,
 from `ent_vw.multi_channel_detail_day` mt
left join `ent_vw.ctd_path_summary_day` pd
on (lower(mt.video_series_nm) like '%nfl football%'and 
mt.visit_session_id = pd.visit_session_id 
and pd.reporting_series_nm = 'Live TV' and
lower(pd.video_nm) like '%nfl%'
and extract(dayofweek from mt.day_dt) = 1
) 
where pd.day_dt  between   '2022-09-10' and '2023-01-30'
and mt.day_dt  between   '2022-09-10' and '2023-01-30'    
and (lower(mt.reporting_series_nm) like '%local%' or lower(mt.reporting_series_nm) like '%live%')
and lower(mt.video_series_nm) like '%nfl football%'
)

-- select * except (visit_session)
-- from one

select

WEEK,
case when last_touch_short_path in ('Global Nav', 'Live TV Network Selection') then 'Global Nav-Live TV'
when last_touch_short_path = 'Homepage Carousel' then 'Homepage Carousel -On Now' 
when last_touch_short_path = 'Homepage Marquee' then 'Homepage Marquee'
else 'Other' end as last_touch_group,
sum(video_playback_ind) as Playbacks,
 
from one
where last_touch_short_path is not null
group by 1,2
