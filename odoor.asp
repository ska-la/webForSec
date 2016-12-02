<%
Session.Timeout = 1
Dim fl
  fl = Request.QueryString("f")
Dim numForSec
  numForSec = "0"
Select Case fl
  Case 7
    numForSec = "1578"
  Case 6
    numForSec = "1626"
  Case 5
    numForSec = "1642"
  Case 4
    numForSec = "1658"
  Case 3
    numForSec = "1674"
  Case else
    numForSec = "-1"
End Select
  Response.Buffer = true
  Response.ContentType = "text/plain"
  Response.CharSet = "utf-8"
    set asPageErr = Server.GetLastError()
    set conFiBi = Server.CreateObject("ADODB.Connection")
    set conFbErr = conFiBi.Errors
    conFiBi.Mode = 3
'    conFiBi.Open "DSN=employee_db"
    conFiBi.Open "DSN=accpoint_db"
'  Response.Write(conFiBi.Provider + "; " + conFiBi.Version + "; " + CStr(conFiBi.State) + "; " + CStr(conFiBi.Mode) + "; " + CStr(conFiBi.IsolationLevel) + "<br>")
    set sqlCmd = Server.CreateObject("ADODB.Command")
'    sqlCmd.CommandText = "SELECT current_time FROM rdb$database"
'    sqlCmd.CommandText = "UPDATE project SET product='other' WHERE team_leader=85"
    sqlCmd.CommandText = "INSERT INTO events   (D,T,PCARD,PUSER,PCOMPUTER,APPLICATION,EVENT,STATUS,POBJECT,PKEY,PALEVEL,PGLEVEL,COMMENTTYPE,COMMENT,PAZONEIN,PAZONEOUT,PVIDEO,PCARDTYPE,DFROM,DTO,PMAKET,LOBJECT)    VALUES ((select ( datediff(day from date '1-Jan-0001' to current_date) + 1 ) from rdb$database),(select datediff(millisecond from time '0:00:00.000' to current_time) from rdb$database),0,7,13,5,127,Null," + numForSec + ",0,0,0,133,Null,0,0,0,0,Null,Null,0,Null)"
    sqlCmd.CommandTimeout = 5
    sqlCmd.CommandType = 1
    sqlCmd.Prepared = False
'  Response.Write(sqlCmd.CommandText + "; " + CStr(sqlCmd.CommandTimeout) + "; " + CStr(sqlCmd.CommandType) + "; " + sqlCmd.Name + "; " + CStr(CInt(sqlCmd.Prepared)) + "; " + CStr(sqlCmd.State) + "<br><hr><br>")
    conFiBi.BeginTrans
    conFiBi.Execute("INSERT INTO evout (EVENT,POBJECT,INFO,MISC) VALUES (133," + numForSec + ",6,-1)")
    conFiBi.Execute sqlCmd.CommandText
    conFiBi.CommitTrans
'    set sqlRes = conFiBi.Execute(sqlCmd.CommandText)
'    for each x in sqlRes.Fields
'  Response.Write(CStr(x.Name) + ": " + CStr(x.Value) + "<br>")
'    next
    conFiBi.Close
  Response.Flush

Session.Abandon
%>

