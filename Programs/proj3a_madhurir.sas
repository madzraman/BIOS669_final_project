%LET job=proj3a;
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
*  Job name:      proj3a_madhurir.sas   
*
*  Purpose:       Identify best shot takers on Real Madrid.
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

DATA att;
	SET ucl.attempts;
	DROP serial;
RUN;


PROC SQL;
	CREATE TABLE best_shottakers AS
		SELECT
			player_name,
			position,
			on_target,
			off_target,
			blocked,
			total_attempts,
			on_target/off_target AS TargetRatio FORMAT=8.2 LABEL="Ratio of Shots /On Target vs. Off Target",
			on_target/total_attempts AS PercentageOnTarget FORMAT=PERCENT8.2
		FROM att
		WHERE 
			club IN ("Real Madrid") AND
			total_attempts > 5
		ORDER BY
			TargetRatio DESC,
			PercentageOnTarget DESC;
QUIT;

PROC PRINT DATA=best_shottakers;
RUN;

/*RTF output, since there are some "weird" characters in player and club names*/
OPTIONS MISSING=' ';
ODS RTF FILE="&outdir/Outputs/&job._&onyen..RTF" STYLE=JOURNAL BODYTITLE;

TITLE "2021/2022 UEFA Champions League: Top Shot Takers on Real Madrid";
FOOTNOTE1 "Table 4.";
FOOTNOTE2 " ";
FOOTNOTE3 "Job &job._&onyen run on &sysdate at &systime";
PROC REPORT DATA=best_shottakers;
	COLUMN (player_name position) ('Raw Data' on_target total_attempts) ('Shot Statistics' TargetRatio PercentageOnTarget);
	DEFINE player_name / DISPLAY "Player" 
					     STYLE(COLUMN)=[fontsize=8pt just=left CELLWIDTH=1.5CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=2CM];
	DEFINE position / DISPLAY "Position" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b JUST=CENTER CELLWIDTH=2CM];
	DEFINE on_target / DISPLAY "Shots On Target" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=2.5CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=2.5CM];
	DEFINE total_attempts / DISPLAY "Total Shot Attempts" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=3CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=3CM];
	DEFINE TargetRatio / DISPLAY "Ratio of Shots /On Target vs. Off Target" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=3CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=3CM];
	DEFINE PercentageOnTarget / DISPLAY "Percentage of /Shots on Target" 
					     STYLE(COLUMN)=[fontsize=8pt just=center CELLWIDTH=3CM] 
					     STYLE(HEADER)=[fontweight=bold just=center vjust=b CELLWIDTH=3CM];
	COMPUTE PercentageOnTarget;
		IF (PercentageOnTarget > 0.5) THEN DO;
			CALL DEFINE(_ROW_,"STYLE","STYLE=[BACKGROUND=cxD5F5E3]");
		END;
	ENDCOMP;
	
RUN;

	
ODS RTF CLOSE;

proc printto; run; /*closes open log file*/
