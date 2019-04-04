<!---
	Template name:
	Creation Date:
	Original programmer:
	Version number: 1.0
	Last Revision:
	Revised by:
	Purpose:

--->

<cfparam name="sched_num" default ="0">
<cfif not IsDefined("get_them_all")>
	<cfoutput>
		<cfset checkday = DateFormat(now(),"yyyy/mm/dd")>
		<cfset checktime = TimeFormat(now(), "HH:mm:ss")>
		<cfquery name="get_them_all" datasource = "checklist">
			SELECT *
			FROM tbl_schedule
			WHERE schedule_num = #sched_num#
			LIMIT 1
		</cfquery>
	</cfoutput>
</cfif>


<cfset internal_alert = 0>
<cfset line_end = chr(13) & chr(10)>
<cfset zero_alert = "FALSE">
<cfset alert_string = "">
<cfif not IsDefined("alerted")>
	<cfset alerted = 0>
</cfif>
<cfif not IsDefined("global_alert_string")>
	<cfset global_alert_string = "">
</cfif>



<cfoutput>
<!--- Processing of your checks goes in this section --->
	<cfset OMG = false>

	<cfquery name="getHeartbeat" datasource="heartbeats">
		SELECT hbdt FROM tbl_heartbeeps WHERE `system`='MasterPanel'
	</cfquery>

	DateTime from heartbeats.tbl_heartbeeps on MedvoiceDB for MasterPanel: #getHeartbeat.hbdt#.<br />
	<cfset checkDateTime = DateAdd("n", -5, now())>
	DateTime for check: #checkDateTime#.<br /><br />

	Comparison Value (must be equal to or greater than zero to pass): #DateCompare(getHeartbeat.hbdt,checkDateTime)#.<br />
	<cfif DateCompare(getHeartbeat.hbdt,checkDateTime) lt 0>
		<cfset OMG = true>
	</cfif>



		<cfif OMG EQ true>
			<cfset zero_alert = "TRUE">
			<cfset internal_alert = 1>
			<cfset alerted = 1>
			<cfset alert_string = #alert_string# & " A check to see if the MasterPanel is running has failed. " & #line_end#>
		</cfif>

		<cfif OMG EQ false>
			<cfset alert_string = "No alerts to be reported">
		</cfif>

	<cfquery name="update_result" datasource="checklist">
		INSERT INTO tbl_results(template_run, date_run, failed, time_run)
		VALUES (#get_them_all.schedule_num#, <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, #internal_alert#, <cfqueryparam value="#now()#" cfsqltype="cf_sql_time">)
	</cfquery>
	<cfif OMG is true>
		<cfquery name="setalert" datasource="checklist">
			INSERT INTO tbl_failures(result_number,
									date_failed,
									acknowledged,
									details,
									time_failed,
									template_name)
			VALUES(#get_them_all.schedule_num#,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					0,
					'MasterPanel check failed',
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_time">,
					'#get_them_all.template_name#')
		</cfquery>
		<cfset alerted = 1>
		<cfset run_string = "-------------------------------------------------------" & #line_end#>
		<cfset run_string = #run_string# & "MasterPanel is not running" & #now()# & #line_end#>
		<cfset run_string = #run_string# & "Alert string used - " & #alert_string# & #line_end#>
		<cfset run_string = #run_string# & "-------------------------------------------------------" & #line_end# & #line_end# >

		<cffile action="append"
			file="c:\logs\MasterPanel_Heartbeat_Check.txt"
			output="#run_string#">


	</cfif>

	<br><br><br>#alert_string#<br>

</cfoutput>


<!---<cfdump>--->
