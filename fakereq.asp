<%
Session.Timeout = 1
  Response.Buffer = true
  Response.ContentType = "text/plain"
  Response.CharSet = "UTF-8"
    set asPageErr = Server.GetLastError()
    set conFiBi = Server.CreateObject("ADODB.Connection")
    set conFbErr = conFiBi.Errors
    conFiBi.Mode = 3
    conFiBi.Open "DSN=accpoint_db"
    set sqlCmd = Server.CreateObject("ADODB.Command")
    sqlCmd.CommandText = "SELECT current_time FROM rdb$database"
    sqlCmd.CommandTimeout = 5
    sqlCmd.CommandType = 1
    sqlCmd.Prepared = False
    conFiBi.Execute sqlCmd.CommandText
'    set sqlRes = conFiBi.Execute(sqlCmd.CommandText)
'    for each x in sqlRes.Fields
'  Response.Write(CStr(x.Name) + ": " + CStr(x.Value) + "<br>")
'    next
    conFiBi.Close
  Response.Flush

Session.Abandon
%>

