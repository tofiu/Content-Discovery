CREATE TABLE temp_tl.entry_point_detailed as 
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
)

SELECT
day_dt,
reporting_series_nm,
case when last_touch_feature_detail_desc like 'Homepage Marquee%' then trim(REGEXP_REPLACE(last_touch_feature_detail_desc, r'[^Homepage\sMarquee]', ''))
when last_touch_feature_detail_desc like 'My List%' then trim(REGEXP_REPLACE(last_touch_feature_detail_desc, r'[^My\sList]', ''))
when last_touch_feature_detail_desc like 'End Cards' and v132_cp_end_card_source_type_desc not in ('end of episode', 'end of show') then 'End Cards (excluding end of Episodes)'
when last_touch_feature_detail_desc like 'End Cards' then 'End Cards(including end of Episodes)'
else last_touch_feature_detail_desc
end last_touch,
sum(video_playback_ind) streams
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
group by 1,2,3
