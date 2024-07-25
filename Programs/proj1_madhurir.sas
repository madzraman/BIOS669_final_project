%LET job=proj1;
%LET onyen=madhurir;
%LET outdir=/home/u63529063/bios669/FinalProject;

proc printto log="&outdir/Logs/&job._&onyen..log" new; run; /*opens a log file to write to*/

*********************************************************************
*  Assignment:    Final Project                                         
*                                                                    
*  Description:   Part 1: Goalkeeper analysis
*
*  Name:          Madhuri Raman
*
*  Date:          April 30th, 2024                                    
*------------------------------------------------------------------- 
*  Job name:      proj1_madhurir.sas   
*
*  Purpose:       Identify best performing goalkeepers in UCL 2021/2022 season.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         UCL datasets:
				  goalkeepers			   
*
*  Output:        RTF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
*ODS _ALL_ CLOSE;


LIBNAME ucl "/home/u63529063/bios669/FinalProject/data/sasdatasets" ;

DATA gk;
	SET ucl.goalkeeping;
	DROP serial;
RUN;


PROC SQL;
	CREATE TABLE top_gks AS
		SELECT
			player_name,
			club,
			saved,
			match_played,
			conceded,
			cleansheets,
			saved/match_played AS saved_per_game FORMAT=8.2,
			conceded/match_played AS conceded_per_game FORMAT=8.2,
			cleansheets/match_played AS avg_cleansheets FORMAT=8.2
		FROM gk
		WHERE 
			player_name NOT IN ("Courtois") AND
			match_played >= 5
		ORDER BY
			saved_per_game DESC,
			conceded_per_game ASC,
			avg_cleansheets DESC;
QUIT;

PROC PRINT DATA=top_gks;
RUN;

/*RTF output, since there are some "weird" characters in player and club names*/
OPTIONS MISSING=' ';
ODS RTF FILE="&outdir/Outputs/&job._&onyen..RTF" STYLE=JOURNAL BODYTITLE;

TITLE "2021/2022 UEFA Champions League: Top Performing Goalkeepers";
FOOTNOTE1 "Table 1.";
FOOTNOTE2 " ";
FOOTNOTE3 "Job &job._&onyen run on &sysdate at &systime";
PROC REPORT DATA=top_gks(obs=10);
	COLUMN (player_name club) ('Statistics' saved_per_game conceded_per_game avg_cleansheets);
	DEFINE player_name / DISPLAY "Player" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=4CM] 
					     STYLE(HEADER)=[fontsize=9pt fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE club / DISPLAY "Club" 
					     STYLE(COLUMN)=[fontsize=8pt just=center] 
					     STYLE(HEADER)=[fontsize=9pt fontweight=bold just=center vjust=b JUST=CENTER];
	DEFINE saved_per_game / DISPLAY "Saves per game" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontsize=9pt fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE conceded_per_game / DISPLAY "Goals Conceded /per game" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontsize=9pt fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE avg_cleansheets / DISPLAY "Average/Clean Sheets" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontsize=9pt fontweight=bold just=center vjust=b];
	COMPUTE saved_per_game;
		IF (saved_per_game >= 4) THEN DO;
			CALL DEFINE(_ROW_,"STYLE","STYLE=[BACKGROUND=cxD5F5E3]");
		END;
	ENDCOMP;
RUN;

	
ODS RTF CLOSE;

proc printto; run; /*closes open log file*/
