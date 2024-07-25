%LET job=proj2a;
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
*  Job name:      proj2a_madhurir.sas   
*
*  Purpose:       Identify most common type of goal scored by each team in the tournament.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         UCL datasets:
				  goals			   
*
*  Output:        RTF file     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;


LIBNAME ucl "/home/u63529063/bios669/FinalProject/data/sasdatasets" ;

DATA gs;
	LENGTH club $30;
	SET ucl.goals;
	DROP serial;
RUN;


PROC SQL;
	CREATE TABLE most_common_goal_types AS
		SELECT
			club AS Club,
			SUM(right_foot) AS RightFoot LABEL="Right Foot",
			SUM(left_foot) AS LeftFoot LABEL="Left Foot",
			SUM(headers) AS Headers LABEL="Headers",
			SUM(others) AS Others LABEL="Others",
			SUM(inside_area) AS InsideArea LABEL="Inside Area",
			SUM(outside_areas) AS OutsideArea LABEL="Outside Area",
			SUM(penalties) AS Penalties LABEL="Penalties"
		FROM gs
		GROUP BY club;
QUIT;

* Then create a new column called "Most Common Goal Type" by taking the name of the column with max value (other than total goals column); 
DATA for_report;
	SET most_common_goal_types;
	ARRAY goal_types(*) RightFoot LeftFoot Headers Others;
    max_value_t = MAX(OF goal_types(*));
    max_index_t = WHICHN(max_value_t, OF goal_types(*));
    SELECT(max_index_t); 
        WHEN(1) max_goal_type = 'Right Foot';
        WHEN(2) max_goal_type = 'Left Foot';
        WHEN(3) max_goal_type = 'Headers';
        WHEN(4) max_goal_type = 'Other';
    END;
    
    ARRAY goal_areas(*) InsideArea OutsideArea Penalties;
    max_value_a = MAX(OF goal_areas(*));
    max_index_a = WHICHN(max_value_a, OF goal_areas(*));
    SELECT(max_index_a); 
        WHEN(1) max_goal_area = 'Inside Area';
        WHEN(2) max_goal_area = 'Outside Area';
        WHEN(3) max_goal_area = 'Penalties';
    END;
    DROP max_value_a max_value_t max_index_a max_index_t;
RUN;

*TITLE "Most Common Types of Goals Scored by Each Team";
*PROC PRINT DATA=most_common_goal_types LABEL NOOBS;
*RUN;

*PROC PRINT DATA=for_report LABEL NOOBS;
*RUN;


/*RTF output, since there are some "weird" characters in player and club names*/
OPTIONS MISSING=' ';
ODS RTF FILE="&outdir/Outputs/&job._&onyen..RTF" STYLE=JOURNAL BODYTITLE;

TITLE "2021/2022 UEFA Champions League:";
TITLE2 "Most Common Types of Goals Scored by Each Team";
FOOTNOTE1 "Table 2.";
FOOTNOTE2 " ";
FOOTNOTE3 "Job &job._&onyen run on &sysdate at &systime";
PROC REPORT DATA=for_report;
	COLUMN (club) ('Type' RightFoot LeftFoot Headers Others max_goal_type) ('Area' InsideArea OutsideArea Penalties max_goal_area);
	DEFINE club / DISPLAY "Club" 
					     STYLE(COLUMN)=[fontsize=10pt fontweight=bold fontstyle=italic just=left CELLWIDTH=2.5CM] 
					     STYLE(HEADER)=[fontsize=10pt fontweight=bold just=center vjust=b just=center CELLWIDTH=2.5CM];
	DEFINE RightFoot / DISPLAY "Right Foot" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1.5CM];
	DEFINE LeftFoot / DISPLAY "Left Foot" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1.5CM];
	DEFINE Headers / DISPLAY "Headers" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1CM];
	DEFINE Others / DISPLAY "Other" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1CM];
	DEFINE max_goal_type / DISPLAY "Most Common Type" 
					     STYLE(COLUMN)=[fontsize=8pt fontweight=bold just=center vjust=m CELLWIDTH=2.5CM] 
					     STYLE(HEADER)=[fontsize=8pt fontweight=bold just=center vjust=b CELLWIDTH=2.5CM];
	DEFINE InsideArea / DISPLAY "Inside Area" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1.5CM];
	DEFINE OutsideArea / DISPLAY "Outside Area" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=1CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1.5CM];
	DEFINE Penalties / DISPLAY "Penalties" 
					     STYLE(COLUMN)=[fontsize=8pt just=center vjust=m CELLWIDTH=2CM] 
					     STYLE(HEADER)=[fontsize=8pt just=center vjust=b CELLWIDTH=1CM];
	DEFINE max_goal_area / DISPLAY "Most Common Area" 
					     STYLE(COLUMN)=[fontsize=8pt fontweight=bold just=center vjust=m CELLWIDTH=2.5CM] 
					     STYLE(HEADER)=[fontsize=8pt fontweight=bold just=center vjust=b CELLWIDTH=2.5CM];
	COMPUTE club;
		CALL DEFINE(_col_,"STYLE","STYLE=[BACKGROUND=cxD5F5E3]");
	ENDCOMP;
	COMPUTE max_goal_type;
		CALL DEFINE(_col_,"STYLE","STYLE=[BACKGROUND=cxEEF3F0]");
	ENDCOMP;
	COMPUTE max_goal_area;
		CALL DEFINE(_col_,"STYLE","STYLE=[BACKGROUND=cxEEF3F0]");
	ENDCOMP;
RUN;

	
ODS RTF CLOSE;

proc printto; run; /*closes open log file*/
