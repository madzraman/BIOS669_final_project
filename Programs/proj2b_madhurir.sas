%LET job=proj2b;
%LET onyen=madhurir;
%LET outdir=/home/u63529063/bios669/FinalProject;

proc printto log="&outdir/Logs/&job._&onyen..log" new; run; /*opens a log file to write to*/

*********************************************************************
*  Assignment:    Final Project                                         
*                                                                    
*  Description:   Part 2: Analysis for defenders
*
*  Name:          Madhuri Raman
*
*  Date:          April 30th, 2024                                    
*------------------------------------------------------------------- 
*  Job name:      proj2b_madhurir.sas   
*
*  Purpose:       Identify best tacklers on Real Madrid.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         UCL datasets:
				  defending			   
*
*  Output:        RTF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;


LIBNAME ucl "/home/u63529063/bios669/FinalProject/data/sasdatasets" ;

DATA def;
	SET ucl.defending;
	DROP serial;
RUN;


PROC SQL;
	CREATE TABLE top_tacks AS
		SELECT
			player_name,
			position,
			tackles,
			t_won,
			match_played,
			t_won/tackles AS PercentageTacklesWon FORMAT=PERCENT8.2 LABEL="Percentage of Tackles Won",
			t_won/match_played AS AvgTacklesWonPerMatch FORMAT=8.2,
			tackles/match_played AS AvgTacklesAttemptedPerMatch FORMAT=8.2
		FROM def
		WHERE 
			club IN ("Real Madrid") AND
			tackles > 2
		ORDER BY
			PercentageTacklesWon DESC,
			AvgTacklesWonPerMatch DESC,
			AvgTacklesAttemptedPerMatch DESC;
QUIT;

PROC PRINT DATA=top_tacks;
RUN;

/*RTF output, since there are some "weird" characters in player and club names*/
OPTIONS MISSING=' ';
ODS RTF FILE="&outdir/Outputs/&job._&onyen..RTF" STYLE=JOURNAL BODYTITLE;

TITLE "2021/2022 UEFA Champions League: Top Tacklers on Real Madrid";
FOOTNOTE1 "Table 3.";
FOOTNOTE2 " ";
FOOTNOTE3 "Job &job._&onyen run on &sysdate at &systime";
PROC REPORT DATA=top_tacks(obs=10);
	COLUMN (player_name position) ('Tackling Statistics' PercentageTacklesWon AvgTacklesWonPerMatch AvgTacklesAttemptedPerMatch);
	DEFINE player_name / DISPLAY "Player" 
					     STYLE(COLUMN)=[fontsize=8pt just=left CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE position / DISPLAY "Position" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b JUST=CENTER CELLWIDTH=2CM];
	DEFINE PercentageTacklesWon / DISPLAY "Percentage of /Tackles Won overall" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=4CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=4CM];
	DEFINE AvgTacklesWonPerMatch / DISPLAY "Average Tackles /Won per match" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=3CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=3CM];
	DEFINE AvgTacklesAttemptedPerMatch / DISPLAY "Average Tackles /Attempted per match" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=4CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=4CM];
	COMPUTE PercentageTacklesWon;
		IF (PercentageTacklesWon > 0.5) THEN DO;
			CALL DEFINE(_ROW_,"STYLE","STYLE=[BACKGROUND=cxD5F5E3]");
		END;
	ENDCOMP;
	
RUN;

	
ODS RTF CLOSE;

proc printto; run; /*closes open log file*/
