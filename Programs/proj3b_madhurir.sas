%LET job=proj3b;
%LET onyen=madhurir;
%LET outdir=/home/u63529063/bios669/FinalProject;

proc printto log="&outdir/Logs/&job._&onyen..log" new; run; /*opens a log file to write to*/

*********************************************************************
*  Assignment:    Final Project                                         
*                                                                    
*  Description:   Part 3: Analysis for Attackers
*
*  Name:          Madhuri Raman
*
*  Date:          April 30th, 2024                                    
*------------------------------------------------------------------- 
*  Job name:      proj3b_madhurir.sas   
*
*  Purpose:       Identify best assisters and passers on Real Madrid.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         UCL datasets:
				  attempts			   
*
*  Output:        RTF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;


LIBNAME ucl "/home/u63529063/bios669/FinalProject/data/sasdatasets" ;

DATA attack;
	SET ucl.attacking;
	DROP serial;
RUN;
PROC SORT DATA=attack; BY player_name; RUN;
DATA dis;
	SET ucl.distribution;
	DROP serial;
RUN;
PROC SORT DATA=dis; BY player_name; RUN;
DATA merged_full;
	MERGE attack(in=a) dis(in=d);
	BY player_name;
	IF a;
	IF d;
RUN;


PROC SQL;
	CREATE TABLE best_passers AS
		SELECT
			player_name,
			club,
			position,
			assists,
			pass_accuracy/100 FORMAT=PERCENT8.1 AS PassAccuracy,
			pass_completed/match_played FORMAT=8.2 AS AvgPassesCompletedPerGame
		FROM merged_full
		WHERE match_played >= 5
		ORDER BY
			PassAccuracy DESC,
			assists DESC;
QUIT;


PROC PRINT DATA=best_passers(obs=30);
RUN;


PROC CORR DATA=best_passers out=corrout;
    VAR assists PassAccuracy AvgPassesCompletedPerGame;
RUN;


/*RTF output, since there are some "weird" characters in player and club names*/
OPTIONS MISSING=' ';
ODS RTF FILE="&outdir/Outputs/&job._&onyen..RTF" STYLE=JOURNAL BODYTITLE;

TITLE "2021/2022 UEFA Champions League: Best Passers in the Tournament";
FOOTNOTE1 "Table 5.";
FOOTNOTE2 " ";
FOOTNOTE3 "Job &job._&onyen run on &sysdate at &systime";
PROC REPORT DATA=best_passers(OBS=30);
	COLUMN (player_name club position) ('Pass Statistics' assists PassAccuracy AvgPassesCompletedPerGame);
	DEFINE player_name / DISPLAY "Player" 
					     STYLE(COLUMN)=[fontsize=8pt just=left CELLWIDTH=1.5CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE club / DISPLAY "Club" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b JUST=CENTER CELLWIDTH=2CM];
	DEFINE position / DISPLAY "Position" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b JUST=CENTER CELLWIDTH=2CM];
	DEFINE assists / DISPLAY "Assists" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=1CM];
	DEFINE PassAccuracy / DISPLAY "Pass Accuracy" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE AvgPassesCompletedPerGame / DISPLAY "Average Passes /Completed per game" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=3CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=3CM];
	COMPUTE PassAccuracy;
		IF (PassAccuracy > 0.916) THEN DO;
			CALL DEFINE(_ROW_,"STYLE","STYLE=[BACKGROUND=cxEDEDED]");
		END;
	ENDCOMP;
	COMPUTE club;
		IF (club = "Real Madrid") THEN DO;
			CALL DEFINE(_ROW_,"STYLE","STYLE=[fontweight=bold]");
		END;
	ENDCOMP;
	
RUN;

	
ODS RTF CLOSE;

proc printto; run; /*closes open log file*/
