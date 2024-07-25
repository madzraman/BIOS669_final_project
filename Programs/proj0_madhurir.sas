%LET job=proj0;
%LET onyen=madhurir;
%LET outdir=/home/u63529063/bios669/FinalProject/data/sasdatasets;

proc printto log="/home/u63529063/bios669/FinalProject/Logs/&job._&onyen..log" new; run; /*opens a log file to write to*/

*********************************************************************
*  Assignment:    Final Project                                         
*                                                                    
*  Description:   Part 0: CSV -> SAS datasets
*
*  Name:          Madhuri Raman
*
*  Date:          April 30th, 2024                                    
*------------------------------------------------------------------- 
*  Job name:      proj1.sas   
*
*  Purpose:       Convert csv data files to sas datasets and save permanently.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         UCL datasets			   
*
*  Output:        SAS datasets saved to outdir    
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN NOFULLSTIMER;

*ODS _ALL_ CLOSE;

LIBNAME out "&outdir.";

%MACRO csv_to_sas(ds_name=);
	PROC IMPORT DATAFILE="/home/u63529063/bios669/FinalProject/data/csvs/&ds_name..csv"
	        	OUT=&ds_name.
		        DBMS=CSV
	        	REPLACE;
	     GETNAMES=YES;
	RUN;
	DATA out.&ds_name.;
   		SET &ds_name.;
	RUN;
%MEND csv_to_sas;

%csv_to_sas(ds_name=attacking);
%csv_to_sas(ds_name=attempts);
%csv_to_sas(ds_name=defending);
%csv_to_sas(ds_name=disciplinary);
%csv_to_sas(ds_name=distribution);
%csv_to_sas(ds_name=goalkeeping);
%csv_to_sas(ds_name=goals);
%csv_to_sas(ds_name=key_stats);

proc printto; run; /*closes open log file*/
