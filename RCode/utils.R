# kranke - January 2025
# Utilities for all R scripts

###########################################################################################################
summarize_athletes <- function( leaguedf, idxdf, athldf, idxfilter, colsummary, teamdoc, nationId ) {
  # Summarize athletes file and fill league dataframe
  leaguedf$athletesCount[ idxdf ]  = sum( idxfilter )
  athldf[, colsummary ]            = lapply( athldf[, colsummary ], as.numeric )
  leaguedf[ idxdf, colsummary ]    = apply( athldf[ idxfilter, colsummary ], 2, mean  )
  leaguedf$wage[ idxdf ]           = leaguedf$wage[ idxdf ] * leaguedf$athletesCount[ idxdf ]
  leaguedf$weeklyWage[ idxdf ]     = paste( round( leaguedf$wage[ idxdf ]/1e3 ), 'k', sep = '' )
  leaguedf$percentItalian[ idxdf ] = paste( sprintf("%.1f", sum( as.numeric( athldf[ idxfilter, 'nationId' ] ) == nationId )/sum( idxfilter )*100 ), '%', sep = '')
  leaguedf$teamName[ idxdf ]       = xml_text( xml_find_first( teamdoc, 'teamName' ) )
  leaguedf$owner[ idxdf ]          = xml_text( xml_find_first( teamdoc, 'owner' ) )
  leaguedf$regionId[ idxdf ]       = xml_text( xml_find_first( teamdoc, 'regionId' ) )
  return( leaguedf )
}
###########################################################################################################


###########################################################################################################
writeLeagueTable <- function( dfwrite, outlabel, digits, outdir, season, level, number, nationName, regionNames, timestmp ) {
  # Write out the league table in html format
  # First create directory if it does not exist
  if ( !dir.exists( outdir ) ) {
    dir.create( outdir )
  }
  dfwrite            = dfwrite[ order( -dfwrite$wage ), ]
  dfwrite$wage       = NULL
  dfwrite$regionName = regionNames[ as.numeric( dfwrite$regionId ) ]
  dfwrite$regionId   = NULL
  dfwrite            = dfwrite[, c( setdiff( names( dfwrite ), "regionName" )[1:3], "regionName", setdiff( names( dfwrite ), "regionName" )[ 4:( length( dfwrite ) - 1 ) ] ) ]
  outfile            = paste( outdir, '/table_league', leagueid, '_', outlabel, '.html', sep = '' )
  outfile_str        = paste( outdir, '/title_league', leagueid, '.html', sep = '' )
  writeLines( print( xtable( dfwrite, digits = digits ), type="html", html.table.attributes="", include.rownames = FALSE  ), outfile )
  cat( paste( "Season ", season, ", ", timestmp, "; ", nationName, " League ", level, ".", number, sep = ''), file = outfile_str  )
}
###########################################################################################################
