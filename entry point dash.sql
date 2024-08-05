CREATE OR REPLACE TABLE temp_tl.entry_point_daily_summary as (
with stage1_originals as (
 select
    distinct
    title,
    -- case
    --   when content_type = "(Movie)" then null
    --   else season_nbr
    -- end as season_nbr,
    -- case
    --   when content_type = "(Movie)" then title
    --   else concat(title," S",season_nbr)
    -- end as show_season_title,
    case 
      when primary_genre_nm = "News & Sports" then secondary_genre_nm 
      else primary_genre_nm 
    end as genre,
    release_strategy,
    case
      when content_type is null then "FEP"
      else "MOVIE"
    end as content_type
  from `ent_summary.pplus_original_premiere_date`
  where
    premeire_dt <= current_date()
),
stage2_originals_streaming as(

SELECT day_dt,
reporting_series_nm,
case 
  when lower(last_touch_feature_desc) like '%homepage%carousel%' then 'Homepage Carousel'
  when lower(last_touch_feature_desc) like 'homepage' then 'Homepage Carousel'
  when lower(last_touch_feature_desc) like '%content page%' then 'Content Page'
  when lower(last_touch_feature_desc) like '%cbs%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%nickelodeon%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%mtv%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%smithsonian%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%comedy central%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%bet%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%showtime%' then 'Showtime Hub'
  when lower(last_touch_feature_desc) like '%thematic%' then 'Thematic Hub'
  else last_touch_feature_desc end last_touch,
"Includes All Features" flag,
"Overal Streams" stream_type,
sum(video_playback_ind) streams #updated to align with product

FROM `ent_vw.ctd_path_summary_day` a join stage1_originals b on a.reporting_series_nm = b.title
where day_dt between '2022-01-01' and current_date()
    and last_touch_feature_desc is not null
    and report_suite_id_nm not in (
      'cbsicbsau',
      'cbsicbsca',
      'cbsicbstve'
    )
    AND report_suite_id_nm = 'cnetcbscomsite'  #updated to align with product
    and v1_brand_nm not like 'pplusintl_%'
    and v1_brand_nm like 'pplus_%'
    AND LOWER(reporting_content_type_cd) IN ('movie', 'fep','live')  #updated to align with product
    AND LOWER(subscription_state_desc) IN ("trial", "sub", "discount offer")  #updated to align with product
    AND LOWER(subscription_package_desc) IN ('cf', 'lc', 'lcp', 'cf-sho', 'lc-sho', 'lcp-sho')  #updated to align with product
group by 1,2,3,4
--order by 2 desc
UNION ALL 

select
day_dt,
reporting_series_nm,
'End Card(excludes end of episodes)' last_touch,
"Excludes End Card - End of Episode, Content Page - Episodes, Homepage Carousel - Keep Watching" flag,
"Overal Streams" stream_type,
sum(video_playback_ind) streams #updated to align with product
from `ent_vw.ctd_path_summary_day` a join stage1_originals b on a.reporting_series_nm = b.title
where day_dt between '2022-01-01' and current_date()
and lower(last_touch_feature_desc) like 'end%card%'
and v132_cp_end_card_source_type_desc <> 'end of episode'
and v132_cp_end_card_source_type_desc <> 'end of show' #updated as of 7/17
and v95_cp_state_desc is not null  #updated to align with product
and v69_registration_id_nbr is not null
and v69_registration_id_nbr != ''
and report_suite_id_nm not in (
      'cbsicbsau',
      'cbsicbsca',
      'cbsicbstve' )
    AND report_suite_id_nm = 'cnetcbscomsite'  #updated to align with product
    and v1_brand_nm not like 'pplusintl_%'
    and v1_brand_nm like 'pplus_%'
    AND LOWER(reporting_content_type_cd) IN ('movie', 'fep','live')  #updated to align with product
    AND LOWER(subscription_state_desc) IN ("trial", "sub", "discount offer")  #updated to align with product
    AND LOWER(subscription_package_desc) IN ('cf', 'lc', 'lcp', 'cf-sho', 'lc-sho', 'lcp-sho')  #updated to align with product 
group by 1,2,3

UNION ALL

SELECT 
day_dt,
reporting_series_nm,
case when lower(last_touch_feature_desc) like '%homepage%carousel%' then 'Homepage Carousel'
       when lower(last_touch_feature_desc) like 'homepage' then 'Homepage Carousel'
       when lower(last_touch_feature_desc) like '%content page%' then 'Content Page'
       when lower(last_touch_feature_desc) like '%cbs%' then 'CBS Brand Hub'
       when lower(last_touch_feature_desc) like '%nickelodeon%' then 'Nickelodeon Brand Hub'
       when lower(last_touch_feature_desc) like '%mtv%' then 'MTV Brand Hub'
       when lower(last_touch_feature_desc) like '%smithsonian%' then 'Smithsonian Brand Hub'
       when lower(last_touch_feature_desc) like '%comedy central%' then 'CC Brand Hub'
       when lower(last_touch_feature_desc) like '%bet%' then 'BET Brand Hub'
       when lower(last_touch_feature_desc) like '%showtime%' then 'Showtime Hub'
       when lower(last_touch_feature_desc) like '%thematic%' then 'Thematic Hub'
else last_touch_feature_desc end last_touch,
"Excludes End Card - End of Episode, Content Page - Episodes, Homepage Carousel - Keep Watching" flag,
"Overal Streams" stream_type,
sum(video_playback_ind) streams #updated to align with product

FROM `ent_vw.ctd_path_summary_day` a join stage1_originals b on a.reporting_series_nm = b.title
where day_dt between '2022-01-01' and current_date()
    and last_touch_feature_desc is not null
    and report_suite_id_nm not in (
      'cbsicbsau',
      'cbsicbsca',
      'cbsicbstve'
    )
    AND report_suite_id_nm = 'cnetcbscomsite'  #updated to align with product
    and v1_brand_nm not like 'pplusintl_%'
    and v1_brand_nm like 'pplus_%'
    AND LOWER(reporting_content_type_cd) IN ('movie', 'fep','live')  #updated to align with product
    AND LOWER(subscription_state_desc) IN ("trial", "sub", "discount offer")  #updated to align with product
    AND LOWER(subscription_package_desc) IN ('cf', 'lc', 'lcp', 'cf-sho', 'lc-sho', 'lcp-sho')  #updated to align with product
    and lower(last_touch_feature_desc) not in ('end cards')
    and last_touch_feature_detail_desc not in ('Homepage Carousel - Keep Watching','Content Page - Episodes')
group by 1,2,3,4),

stage3_overall as (
SELECT day_dt,
"P+ Overall" as reporting_series_nm,
case 
  when lower(last_touch_feature_desc) like '%homepage%carousel%' then 'Homepage Carousel'
  when lower(last_touch_feature_desc) like 'homepage' then 'Homepage Carousel'
  when lower(last_touch_feature_desc) like '%content page%' then 'Content Page'
  when lower(last_touch_feature_desc) like '%cbs%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%nickelodeon%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%mtv%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%smithsonian%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%comedy central%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%bet%' then 'Brand Hub'
  when lower(last_touch_feature_desc) like '%showtime%' then 'Showtime Hub'
  when lower(last_touch_feature_desc) like '%thematic%' then 'Thematic Hub'
  else last_touch_feature_desc end last_touch,
"Includes All Features" flag,
"Overal Streams" stream_type,
sum(video_playback_ind) streams #updated to align with product

FROM `ent_vw.ctd_path_summary_day` a 
where day_dt between '2022-01-01' and current_date()
    and last_touch_feature_desc is not null
    and report_suite_id_nm not in (
      'cbsicbsau',
      'cbsicbsca',
      'cbsicbstve'
    )
    AND report_suite_id_nm = 'cnetcbscomsite'  #updated to align with product
    and v1_brand_nm not like 'pplusintl_%'
    and v1_brand_nm like 'pplus_%'
    AND LOWER(reporting_content_type_cd) IN ('movie', 'fep','live')  #updated to align with product
    AND LOWER(subscription_state_desc) IN ("trial", "sub", "discount offer")  #updated to align with product
    AND LOWER(subscription_package_desc) IN ('cf', 'lc', 'lcp', 'cf-sho', 'lc-sho', 'lcp-sho')  #updated to align with product
group by 1,2,3,4
--order by 2 desc
UNION ALL 

select
day_dt,
"P+ Overall" as reporting_series_nm,
'End Card(excludes end of episodes)' last_touch,
"Excludes End Card - End of Episode, Content Page - Episodes, Homepage Carousel - Keep Watching" flag,
"Overal Streams" stream_type,
sum(video_playback_ind) streams #updated to align with product
from `ent_vw.ctd_path_summary_day` a 
where day_dt between '2022-01-01' and current_date()
and lower(last_touch_feature_desc) like 'end%card%'
and v132_cp_end_card_source_type_desc <> 'end of episode'
and v132_cp_end_card_source_type_desc <> 'end of show' #updated as of 7/17
and v95_cp_state_desc is not null  #updated to align with product
and v69_registration_id_nbr is not null
and v69_registration_id_nbr != ''
and report_suite_id_nm not in (
      'cbsicbsau',
      'cbsicbsca',
      'cbsicbstve' )
    AND report_suite_id_nm = 'cnetcbscomsite'  #updated to align with product
    and v1_brand_nm not like 'pplusintl_%'
    and v1_brand_nm like 'pplus_%'
    AND LOWER(reporting_content_type_cd) IN ('movie', 'fep','live')  #updated to align with product
    AND LOWER(subscription_state_desc) IN ("trial", "sub", "discount offer")  #updated to align with product
    AND LOWER(subscription_package_desc) IN ('cf', 'lc', 'lcp', 'cf-sho', 'lc-sho', 'lcp-sho')  #updated to align with product 
group by 1,2,3

UNION ALL

SELECT 
day_dt,
"P+ Overall" as reporting_series_nm,
case when lower(last_touch_feature_desc) like '%homepage%carousel%' then 'Homepage Carousel'
       when lower(last_touch_feature_desc) like 'homepage' then 'Homepage Carousel'
       when lower(last_touch_feature_desc) like '%content page%' then 'Content Page'
       when lower(last_touch_feature_desc) like '%cbs%' then 'CBS Brand Hub'
       when lower(last_touch_feature_desc) like '%nickelodeon%' then 'Nickelodeon Brand Hub'
       when lower(last_touch_feature_desc) like '%mtv%' then 'MTV Brand Hub'
       when lower(last_touch_feature_desc) like '%smithsonian%' then 'Smithsonian Brand Hub'
       when lower(last_touch_feature_desc) like '%comedy central%' then 'CC Brand Hub'
       when lower(last_touch_feature_desc) like '%bet%' then 'BET Brand Hub'
       when lower(last_touch_feature_desc) like '%showtime%' then 'Showtime Hub'
       when lower(last_touch_feature_desc) like '%thematic%' then 'Thematic Hub'
else last_touch_feature_desc end last_touch,
"Excludes End Card - End of Episode, Content Page - Episodes, Homepage Carousel - Keep Watching" flag,
"Overal Streams" stream_type,
sum(video_playback_ind) streams #updated to align with product

FROM `ent_vw.ctd_path_summary_day` a 
where day_dt between '2022-01-01' and current_date()
    and last_touch_feature_desc is not null
    and report_suite_id_nm not in (
      'cbsicbsau',
      'cbsicbsca',
      'cbsicbstve'
    )
    AND report_suite_id_nm = 'cnetcbscomsite'  #updated to align with product
    and v1_brand_nm not like 'pplusintl_%'
    and v1_brand_nm like 'pplus_%'
    AND LOWER(reporting_content_type_cd) IN ('movie', 'fep','live')  #updated to align with product
    AND LOWER(subscription_state_desc) IN ("trial", "sub", "discount offer")  #updated to align with product
    AND LOWER(subscription_package_desc) IN ('cf', 'lc', 'lcp', 'cf-sho', 'lc-sho', 'lcp-sho')  #updated to align with product
    and lower(last_touch_feature_desc) not in ('end cards')
    and last_touch_feature_detail_desc not in ('Homepage Carousel - Keep Watching','Content Page - Episodes')
group by 1,2,3,4)

select * from stage2_originals_streaming
union all 
select * from stage3_overall)
