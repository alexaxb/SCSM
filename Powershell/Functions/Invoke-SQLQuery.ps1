function Invoke-SQLQuery {
    param(
        [string] $Servername = ".\SQLEXPRESS",
        [string] $Database = "MasterData",
        [string] $SqlCommand = $(throw "Please specify a query.")
      )

    $connectionString = "Data Source=$Servername; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$Database"
    try{
        $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
        $command = new-object system.data.sqlclient.sqlcommand($SqlCommand,$connection)
        $connection.Open()

        $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataSet) | Out-Null

        $connection.Close()
        $Result=@()
    } catch {
        Throw "Invoke-SQLQuery: $($_)"
    }
    # Process each table
    foreach ($Table in $dataSet.Tables){

        # Process each table row
        for($r=0;$r -lt $Table.Rows.Count; $r++){
            
            $temp=$null
            $hash=@{}

            # Process each column for table row
            for($c=0;$c -lt $Table.Columns.Count; $c++){

                $Column = $Table.Columns[$c].ColumnName
                $Data = $Table.Rows[$r].$Column
                $hash.Add($Column,$Data.ToString().Trim())
            }
            $temp = New-Object -TypeName PSObject -Property $hash
            $Result += $temp

        }
    }
    Return $Result

}
